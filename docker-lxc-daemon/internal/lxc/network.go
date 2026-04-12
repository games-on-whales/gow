package lxc

import (
	"fmt"
	"net"
	"os/exec"
	"strings"
)

const (
	BridgeName = "gow0"
	BridgeCIDR = "10.100.0.1/24"
	BridgeGW   = "10.100.0.1"
	SubnetMask = "255.255.255.0"
)

// EnsureBridge creates the gow0 bridge and assigns it the gateway IP if it
// does not already exist. Idempotent.
func EnsureBridge() error {
	iface, err := net.InterfaceByName(BridgeName)
	if err != nil || iface == nil {
		// Bridge doesn't exist — create it.
		cmds := [][]string{
			{"ip", "link", "add", "name", BridgeName, "type", "bridge"},
			{"ip", "addr", "add", BridgeCIDR, "dev", BridgeName},
			{"ip", "link", "set", BridgeName, "up"},
		}
		for _, args := range cmds {
			if out, err := exec.Command(args[0], args[1:]...).CombinedOutput(); err != nil {
				return fmt.Errorf("network: %v: %s: %w", args, out, err)
			}
		}
	}

	// Ensure IP forwarding and allow localhost-originated packets to be
	// routed to the bridge (needed for port forwarding from localhost).
	sysctls := []string{
		"net.ipv4.ip_forward=1",
		"net.ipv4.conf.all.route_localnet=1",
		"net.ipv4.conf." + BridgeName + ".route_localnet=1",
	}
	for _, s := range sysctls {
		if out, err := exec.Command("sysctl", "-w", s).CombinedOutput(); err != nil {
			return fmt.Errorf("network: sysctl %s: %s: %w", s, out, err)
		}
	}

	// Ensure the gow_nat nftables table exists with the masquerade rule.
	// Using "nft -f" with a table block is idempotent — it merges into any
	// existing table rather than replacing it.
	nftRule := fmt.Sprintf(`
table ip gow_nat {
	chain postrouting {
		type nat hook postrouting priority srcnat; policy accept;
		ip saddr 10.100.0.0/24 oifname != "%s" masquerade
		ct status dnat masquerade
	}
}
`, BridgeName)
	cmd := exec.Command("nft", "-f", "-")
	cmd.Stdin = strings.NewReader(nftRule)
	if out, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("network: nft masquerade: %s: %w", out, err)
	}

	return nil
}

// TeardownBridge removes the gow0 bridge and nftables table.
// Called on daemon shutdown. The bridge and NAT rules are left in place
// so that containers that survive the daemon restart keep networking.
// EnsureBridge is idempotent and will reconcile on the next startup.
func TeardownBridge() {
	// Intentionally left as a no-op. Removing the bridge or nft table
	// while containers are running kills their networking. The next
	// EnsureBridge call on startup will reconcile state.
}

// AddPortForward creates an nftables DNAT rule in the gow_nat table to forward
// traffic from hostPort to containerIP:containerPort.
func AddPortForward(containerIP string, hostPort, containerPort int, proto string) error {
	if proto == "" {
		proto = "tcp"
	}
	// prerouting handles traffic from external interfaces; output handles
	// traffic originating on the host itself (e.g. curl localhost:8080).
	nftRule := fmt.Sprintf(`
table ip gow_nat {
	chain prerouting {
		type nat hook prerouting priority dstnat; policy accept;
		%s dport %d dnat to %s:%d
	}
	chain output {
		type nat hook output priority dstnat; policy accept;
		%s dport %d dnat to %s:%d
	}
}
`, proto, hostPort, containerIP, containerPort,
		proto, hostPort, containerIP, containerPort)

	cmd := exec.Command("nft", "-f", "-")
	cmd.Stdin = strings.NewReader(nftRule)
	if out, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("network: nft port forward: %s: %w", out, err)
	}
	return nil
}

// RemovePortForwards removes all nftables DNAT rules in the gow_nat prerouting
// chain that target the given container IP.
func RemovePortForwards(containerIP string) error {
	target := "dnat to " + containerIP + ":"
	// Clean rules from both prerouting and output chains.
	for _, chain := range []string{"prerouting", "output"} {
		out, err := exec.Command("nft", "-a", "list", "chain", "ip", "gow_nat", chain).CombinedOutput()
		if err != nil {
			continue // chain may not exist
		}
		for _, line := range strings.Split(string(out), "\n") {
			if !strings.Contains(line, target) {
				continue
			}
			parts := strings.Split(line, "# handle ")
			if len(parts) < 2 {
				continue
			}
			handle := strings.TrimSpace(parts[1])
			exec.Command("nft", "delete", "rule", "ip", "gow_nat", chain, "handle", handle).Run()
		}
	}
	return nil
}

// NetworkConfig returns the lxc.conf lines needed to attach a container to
// gow0 with the given static IP.
func NetworkConfig(ip string) []configItem {
	return []configItem{
		{"lxc.net.0.type", "veth"},
		{"lxc.net.0.link", BridgeName},
		{"lxc.net.0.flags", "up"},
		{"lxc.net.0.ipv4.address", ip + "/24"},
		{"lxc.net.0.ipv4.gateway", BridgeGW},
	}
}
