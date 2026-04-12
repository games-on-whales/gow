package lxc

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// configItem is a key/value pair written to an LXC config file.
type configItem struct {
	key   string
	value string
}

// ContainerConfig holds the Docker-layer configuration fields that we
// translate into LXC config items. This is populated from the Docker API
// container-create request body.
type ContainerConfig struct {
	Entrypoint []string
	Cmd        []string
	Env        []string
	Mounts     []MountSpec  // bind mounts
	Devices    []DeviceSpec // host devices to expose
	MemoryBytes int64       // 0 = unlimited
	CPUShares  int64        // 0 = unlimited (relative weight)
	CPUQuota   int64        // microseconds per 100ms period, 0 = unlimited
	// LogFile is where the container console output is written.
	// Set automatically by the manager.
	LogFile string
}

// MountSpec describes a single bind mount.
type MountSpec struct {
	Source      string
	Destination string
	ReadOnly    bool
}

// DeviceSpec describes a host device to expose inside the container.
type DeviceSpec struct {
	PathOnHost      string
	PathInContainer string
}

// rewriteConfig reads the cloned LXC config file, strips problematic lines
// inherited from the download template (userns, apparmor, duplicate network),
// and appends the daemon-managed config items. This is more reliable than
// the go-lxc SetConfigItem API because lxc.include directives are processed
// at container start time and can override in-memory changes.
func rewriteConfig(path string, cfg ContainerConfig, ip, containerName string) error {
	f, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("read config: %w", err)
	}

	var kept []string
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		trimmed := strings.TrimSpace(line)

		switch {
		case strings.Contains(trimmed, "userns.conf"):
			continue
		case strings.HasPrefix(trimmed, "lxc.apparmor.profile"):
			continue
		case strings.HasPrefix(trimmed, "lxc.apparmor.allow_nesting"):
			continue
		case strings.HasPrefix(trimmed, "lxc.net."):
			continue
		case strings.HasPrefix(trimmed, "lxc.idmap"):
			continue
		case strings.HasPrefix(trimmed, "lxc.id_map"):
			continue
		}

		kept = append(kept, line)
	}
	f.Close()
	if err := scanner.Err(); err != nil {
		return fmt.Errorf("scan config: %w", err)
	}

	items := append([]configItem{
		{"lxc.apparmor.profile", "unconfined"},
	}, buildItems(cfg, ip)...)

	out, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("write config: %w", err)
	}
	defer out.Close()

	w := bufio.NewWriter(out)
	for _, line := range kept {
		fmt.Fprintln(w, line)
	}
	fmt.Fprintln(w, "\n# docker-lxc-daemon managed config")
	for _, item := range items {
		fmt.Fprintf(w, "%s = %s\n", item.key, item.value)
	}
	return w.Flush()
}

func buildItems(cfg ContainerConfig, ip string) []configItem {
	var items []configItem

	// Network
	items = append(items, NetworkConfig(ip)...)

	// Environment variables — reject newlines to prevent config injection.
	for _, e := range cfg.Env {
		if strings.ContainsAny(e, "\n\r") {
			continue
		}
		items = append(items, configItem{"lxc.environment", e})
	}

	// Entrypoint + cmd: combined into lxc.init.cmd.
	// LXC runs this as the container's PID 1.
	if combined := combinedCmd(cfg.Entrypoint, cfg.Cmd); combined != "" {
		items = append(items, configItem{"lxc.init.cmd", combined})
	}

	// Bind mounts
	for _, m := range cfg.Mounts {
		opts := "bind,create=dir"
		if m.ReadOnly {
			opts += ",ro"
		}
		// lxc.mount.entry format:
		//   <source> <dest-relative-to-rootfs> <fs-type> <options> 0 0
		dest := strings.TrimPrefix(m.Destination, "/")
		entry := fmt.Sprintf("%s %s none %s 0 0", m.Source, dest, opts)
		items = append(items, configItem{"lxc.mount.entry", entry})
	}

	// Devices
	for _, d := range cfg.Devices {
		dest := d.PathInContainer
		if dest == "" {
			dest = d.PathOnHost
		}
		// Allow access in cgroup and bind-mount the device node
		items = append(items, configItem{
			"lxc.cgroup2.devices.allow",
			deviceCgroupEntry(d.PathOnHost),
		})
		destRel := strings.TrimPrefix(dest, "/")
		items = append(items, configItem{
			"lxc.mount.entry",
			fmt.Sprintf("%s %s none bind,create=file 0 0", d.PathOnHost, destRel),
		})
	}

	// Memory limit
	if cfg.MemoryBytes > 0 {
		items = append(items, configItem{
			"lxc.cgroup2.memory.max",
			fmt.Sprintf("%d", cfg.MemoryBytes),
		})
	}

	// CPU
	if cfg.CPUShares > 0 {
		items = append(items, configItem{
			"lxc.cgroup2.cpu.weight",
			fmt.Sprintf("%d", cpuSharesToWeight(cfg.CPUShares)),
		})
	}
	if cfg.CPUQuota > 0 {
		// Docker CPUQuota is in microseconds; LXC cpu.max is "quota period"
		// where period defaults to 100000 µs.
		items = append(items, configItem{
			"lxc.cgroup2.cpu.max",
			fmt.Sprintf("%d 100000", cfg.CPUQuota),
		})
	}

	// Console log so we can serve it via the logs API
	if cfg.LogFile != "" {
		items = append(items, configItem{"lxc.console.logfile", cfg.LogFile})
	}

	return items
}

// combinedCmd merges entrypoint and cmd the same way Docker does.
func combinedCmd(entrypoint, cmd []string) string {
	var parts []string
	parts = append(parts, entrypoint...)
	parts = append(parts, cmd...)
	if len(parts) == 0 {
		return ""
	}
	// LXC splits lxc.init.cmd on spaces. Quote any argument that contains
	// spaces so commands like `/bin/sh -c "nginx -g 'daemon off;'"` are
	// passed correctly.
	var quoted []string
	for _, p := range parts {
		if strings.Contains(p, " ") {
			quoted = append(quoted, `"`+p+`"`)
		} else {
			quoted = append(quoted, p)
		}
	}
	return strings.Join(quoted, " ")
}

// cpuSharesToWeight converts Docker's legacy CPU shares (1–1024) to cgroup v2
// weight (1–10000). Docker default is 1024 → weight 100.
func cpuSharesToWeight(shares int64) int64 {
	if shares <= 0 {
		return 100
	}
	w := (shares * 10000) / 1024
	if w < 1 {
		return 1
	}
	if w > 10000 {
		return 10000
	}
	return w
}

// deviceCgroupEntry returns a cgroup2 device allow rule for a device path.
// We use "rwm" (read/write/mknod) for all devices passed through.
func deviceCgroupEntry(path string) string {
	major, minor := deviceNumbers(path)
	if major < 0 {
		return "a *:* rwm" // fallback: allow all (avoid failing silently)
	}
	return fmt.Sprintf("c %d:%d rwm", major, minor)
}

// deviceNumbers returns the major/minor numbers for a device file.
// Returns -1,-1 on error.
func deviceNumbers(path string) (int, int) {
	var stat syscallStat
	if err := syscallStatDevice(path, &stat); err != nil {
		return -1, -1
	}
	return int(stat.major), int(stat.minor)
}

// LogFilePath returns the canonical console log file path for a container.
func LogFilePath(lxcPath, name string) string {
	return filepath.Join(lxcPath, "..", "docker-lxc-daemon", "logs", name+".log")
}
