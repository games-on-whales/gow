// Package lxc wraps go-lxc to provide container lifecycle operations for the
// docker-lxc-daemon. All container names managed here are the raw LXC names
// (which double as Docker container IDs).
package lxc

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/games-on-whales/docker-lxc-daemon/internal/image"
	"github.com/games-on-whales/docker-lxc-daemon/internal/oci"
	"github.com/games-on-whales/docker-lxc-daemon/internal/store"
	liblxc "github.com/lxc/go-lxc"
)

// Manager owns all LXC operations on behalf of the daemon.
type Manager struct {
	lxcPath string // e.g. /var/lib/lxc
	store   *store.Store
}

// NewManager creates a Manager that stores containers under lxcPath.
// It ensures the network bridge exists and reconciles state from the
// store with actual LXC container state (e.g. re-applying port forwards
// for containers that are still running after a daemon restart).
func NewManager(lxcPath string, st *store.Store) (*Manager, error) {
	if err := os.MkdirAll(lxcPath, 0o755); err != nil {
		return nil, fmt.Errorf("manager: mkdir %s: %w", lxcPath, err)
	}
	if err := EnsureBridge(); err != nil {
		return nil, fmt.Errorf("manager: bridge: %w", err)
	}
	m := &Manager{lxcPath: lxcPath, store: st}
	m.reconcile()
	return m, nil
}

// reconcile checks the store against actual LXC state on startup. For
// containers that are still running, it re-applies port forwarding rules
// (which may have been lost if nft state was cleared). For containers
// whose LXC directory no longer exists, it cleans them from the store.
func (m *Manager) reconcile() {
	for _, rec := range m.store.ListContainers() {
		if !m.containerExists(rec.ID) {
			log.Printf("reconcile: removing orphaned store entry %s (%s)", rec.Name, rec.ID[:12])
			m.store.RemoveContainer(rec.ID)
			continue
		}
		state, _ := m.State(rec.ID)
		if state == "running" && rec.IPAddress != "" {
			for _, pb := range rec.PortBindings {
				if err := AddPortForward(rec.IPAddress, pb.HostPort, pb.ContainerPort, pb.Proto); err != nil {
					log.Printf("reconcile: port forward %d->%s:%d/%s failed: %v",
						pb.HostPort, rec.IPAddress, pb.ContainerPort, pb.Proto, err)
				}
			}
			log.Printf("reconcile: container %s (%s) still running, port forwards restored",
				rec.Name, rec.ID[:12])
		}
	}
}

// PullImage ensures a template container exists for the given image ref.
// For distro images it runs lxc-create with the download template.
// For app images it creates the base template, starts it, installs packages,
// then stops it — producing a ready-to-clone template.
func (m *Manager) PullImage(ref, arch string, progress func(string)) error {
	resolved, err := image.Resolve(ref, arch)
	if err != nil {
		return err
	}

	// If the template container already exists, nothing to do.
	if m.containerExists(resolved.TemplateContainerName) {
		progress("Image already present")
		return nil
	}

	switch resolved.Kind {
	case image.KindDistro:
		return m.pullDistro(resolved, progress)
	case image.KindApp:
		return m.pullApp(resolved, progress)
	case image.KindOCI:
		return m.pullOCI(resolved, progress)
	}
	return fmt.Errorf("manager: unknown image kind")
}

func (m *Manager) pullDistro(r *image.ResolvedImage, progress func(string)) error {
	progress(fmt.Sprintf("Pulling %s %s/%s from images.linuxcontainers.org",
		r.Ref, r.Distro, r.Release))

	c, err := liblxc.NewContainer(r.TemplateContainerName, m.lxcPath)
	if err != nil {
		return fmt.Errorf("manager: new container %s: %w", r.TemplateContainerName, err)
	}

	opts := liblxc.TemplateOptions{
		Template: "download",
		Distro:   r.Distro,
		Release:  r.Release,
		Arch:     r.Arch,
	}
	if err := c.Create(opts); err != nil {
		return fmt.Errorf("manager: create template %s: %w", r.TemplateContainerName, err)
	}

	// Record image in store.
	return m.store.AddImage(&store.ImageRecord{
		ID:           imageID(r.Distro, r.Release),
		Ref:          r.Ref,
		Distro:       r.Distro,
		Release:      r.Release,
		Arch:         r.Arch,
		TemplateName: r.TemplateContainerName,
		Created:      time.Now(),
	})
}

func (m *Manager) pullApp(r *image.ResolvedImage, progress func(string)) error {
	// 1. Ensure the base distro template exists.
	progress(fmt.Sprintf("Pulling base image %s for %s", r.BaseRef, r.Ref))
	baseResolved, err := image.Resolve(r.BaseRef, r.Arch)
	if err != nil {
		return err
	}
	if !m.containerExists(baseResolved.TemplateContainerName) {
		if err := m.pullDistro(baseResolved, progress); err != nil {
			return err
		}
	}

	// 2. Clone base → app template.
	progress(fmt.Sprintf("Creating app template for %s", r.Ref))
	base, err := liblxc.NewContainer(baseResolved.TemplateContainerName, m.lxcPath)
	if err != nil {
		return fmt.Errorf("manager: open base template: %w", err)
	}
	if err := base.Clone(r.TemplateContainerName, liblxc.CloneOptions{
		Backend:  liblxc.Directory,
		Snapshot: false,
	}); err != nil {
		return fmt.Errorf("manager: clone base → app template: %w", err)
	}

	// 3. Rewrite the cloned config to fix AppArmor/userns issues, set up
	//    networking, and write resolv.conf so package installs can resolve DNS.
	//    Use a temporary IP that we free after the build completes.
	templateCfgPath := filepath.Join(m.lxcPath, r.TemplateContainerName, "config")
	templateCfg := ContainerConfig{}
	ip, err := m.store.AllocateIP()
	if err != nil {
		return fmt.Errorf("manager: allocate IP for app template: %w", err)
	}
	defer m.store.FreeIP(ip) // Template doesn't need a permanent IP.

	if err := rewriteConfig(templateCfgPath, templateCfg, ip, r.TemplateContainerName); err != nil {
		return fmt.Errorf("manager: rewrite app template config: %w", err)
	}
	templateRootfs := filepath.Join(m.lxcPath, r.TemplateContainerName, "rootfs")
	resolvPath := filepath.Join(templateRootfs, "etc", "resolv.conf")
	os.Remove(resolvPath)
	os.WriteFile(resolvPath, []byte("nameserver 8.8.8.8\nnameserver 1.1.1.1\n"), 0o644)

	// Start the app template container temporarily.
	appTemplate, err := liblxc.NewContainer(r.TemplateContainerName, m.lxcPath)
	if err != nil {
		return fmt.Errorf("manager: open app template: %w", err)
	}
	if err := appTemplate.Start(); err != nil {
		return fmt.Errorf("manager: start app template: %w", err)
	}
	defer appTemplate.Stop()

	if err := waitRunning(appTemplate, 30*time.Second); err != nil {
		return fmt.Errorf("manager: app template did not start: %w", err)
	}

	// 4. Install packages.
	if len(r.App.Packages) > 0 {
		progress(fmt.Sprintf("Installing packages: %s", strings.Join(r.App.Packages, " ")))
		installCmd := buildInstallCmd(r.Distro, r.App.Packages)
		if err := m.runInContainer(appTemplate, installCmd); err != nil {
			return fmt.Errorf("manager: install packages: %w", err)
		}
	}

	// 5. Run post-install script if any.
	if r.App.PostInstall != "" {
		progress("Running post-install")
		if err := m.runInContainer(appTemplate, r.App.PostInstall); err != nil {
			return fmt.Errorf("manager: post-install: %w", err)
		}
	}
	// Stop is handled by defer above.

	// 7. Record image in store.
	return m.store.AddImage(&store.ImageRecord{
		ID:           imageID(r.Distro, r.Release),
		Ref:          r.Ref,
		Distro:       r.Distro,
		Release:      r.Release,
		Arch:         r.Arch,
		TemplateName: r.TemplateContainerName,
		Created:      time.Now(),
	})
}

// pullOCI pulls an arbitrary OCI/Docker image via skopeo + umoci, unpacks it
// to a rootfs, and creates an LXC template container from it.
func (m *Manager) pullOCI(r *image.ResolvedImage, progress func(string)) error {
	ociStoreDir := filepath.Join(filepath.Dir(m.lxcPath), "docker-lxc-daemon", "oci")

	cfg, rootfsPath, err := oci.Pull(ociStoreDir, r.Ref, progress)
	if err != nil {
		return fmt.Errorf("manager: oci pull: %w", err)
	}

	// Create the LXC template container directory and move the rootfs into it.
	progress("Creating LXC template from OCI rootfs")
	templateDir := filepath.Join(m.lxcPath, r.TemplateContainerName)
	templateRootfs := filepath.Join(templateDir, "rootfs")
	if err := os.MkdirAll(templateDir, 0o755); err != nil {
		return fmt.Errorf("manager: mkdir template: %w", err)
	}

	// Move the unpacked rootfs into the LXC container directory.
	if err := os.Rename(rootfsPath, templateRootfs); err != nil {
		// Rename fails across filesystems; fall back to copy.
		out, cpErr := exec.Command("cp", "-a", rootfsPath, templateRootfs).CombinedOutput()
		if cpErr != nil {
			return fmt.Errorf("manager: copy rootfs: %s: %w", out, cpErr)
		}
	}

	// Write a minimal LXC config for the template.
	minimalConfig := fmt.Sprintf(`lxc.include = /usr/share/lxc/config/common.conf
lxc.arch = linux64
lxc.rootfs.path = dir:%s
lxc.uts.name = %s
`, templateRootfs, r.TemplateContainerName)

	configPath := filepath.Join(templateDir, "config")
	if err := os.WriteFile(configPath, []byte(minimalConfig), 0o644); err != nil {
		return fmt.Errorf("manager: write template config: %w", err)
	}

	// Write resolv.conf into rootfs.
	resolvPath := filepath.Join(templateRootfs, "etc", "resolv.conf")
	os.Remove(resolvPath)
	os.MkdirAll(filepath.Dir(resolvPath), 0o755)
	os.WriteFile(resolvPath, []byte("nameserver 8.8.8.8\nnameserver 1.1.1.1\n"), 0o644)

	// Clean up the OCI layout/bundle now that rootfs is in place.
	oci.Cleanup(ociStoreDir, r.Ref)

	progress("Image ready")
	return m.store.AddImage(&store.ImageRecord{
		ID:            "oci_" + oci.SafeDirName(r.Ref),
		Ref:           r.Ref,
		Arch:          r.Arch,
		TemplateName:  r.TemplateContainerName,
		Created:       time.Now(),
		OCIEntrypoint: cfg.Entrypoint,
		OCICmd:        cfg.Cmd,
		OCIEnv:        cfg.Env,
		OCIWorkingDir: cfg.WorkingDir,
		OCIPorts:      cfg.Ports,
	})
}

// CreateContainer clones the image template, applies the given config, and
// prepares (but does not start) the container.
func (m *Manager) CreateContainer(id, imageRef string, cfg ContainerConfig) error {
	rec := m.store.GetImage(imageRef)
	if rec == nil {
		return fmt.Errorf("manager: image %q not found; run pull first", imageRef)
	}

	// Clone template → new container.
	tmpl, err := liblxc.NewContainer(rec.TemplateName, m.lxcPath)
	if err != nil {
		return fmt.Errorf("manager: open template %s: %w", rec.TemplateName, err)
	}
	if err := tmpl.Clone(id, liblxc.CloneOptions{
		Backend:  liblxc.Directory,
		Snapshot: false,
	}); err != nil {
		return fmt.Errorf("manager: clone %s → %s: %w", rec.TemplateName, id, err)
	}

	// Allocate IP and configure networking + rest of config.
	// If anything below fails, destroy the cloned container to avoid orphans.
	ip, err := m.store.AllocateIP()
	if err != nil {
		m.destroyOrphan(id)
		return fmt.Errorf("manager: allocate IP: %w", err)
	}

	// Set console log path.
	cfg.LogFile = LogFilePath(m.lxcPath, id)
	if err := os.MkdirAll(filepath.Dir(cfg.LogFile), 0o755); err != nil {
		return fmt.Errorf("manager: mkdir log dir: %w", err)
	}

	// Rewrite the cloned config file directly. The go-lxc SetConfigItem
	// API doesn't reliably override settings inherited from lxc.include
	// directives, so we read-modify-write the text config instead.
	configPath := filepath.Join(m.lxcPath, id, "config")
	if err := rewriteConfig(configPath, cfg, ip, id); err != nil {
		return fmt.Errorf("manager: rewrite config: %w", err)
	}

	// Ensure the container has working DNS resolution by writing resolv.conf
	// into the rootfs before first start. Ubuntu uses a symlink to
	// systemd-resolved which won't exist in the container, so remove any
	// existing symlink first.
	rootfs := filepath.Join(m.lxcPath, id, "rootfs")
	resolvPath := filepath.Join(rootfs, "etc", "resolv.conf")
	os.Remove(resolvPath) // remove symlink or stale file; ignore error
	if err := os.MkdirAll(filepath.Dir(resolvPath), 0o755); err != nil {
		return fmt.Errorf("manager: mkdir etc in rootfs: %w", err)
	}
	if err := os.WriteFile(resolvPath, []byte("nameserver 8.8.8.8\nnameserver 1.1.1.1\n"), 0o644); err != nil {
		return fmt.Errorf("manager: write resolv.conf: %w", err)
	}

	// Update store record with IP.
	if storeRec := m.store.GetContainer(id); storeRec != nil {
		storeRec.IPAddress = ip
		return m.store.AddContainer(storeRec)
	}
	return nil
}

// StartContainer starts a stopped container.
func (m *Manager) StartContainer(id string) error {
	c, err := m.openContainer(id)
	if err != nil {
		return err
	}
	if c.State() == liblxc.RUNNING {
		return nil
	}
	if err := c.Start(); err != nil {
		return fmt.Errorf("manager: start %s: %w", id, err)
	}
	return waitRunning(c, 30*time.Second)
}

// StopContainer stops a running container gracefully, waiting up to timeout.
func (m *Manager) StopContainer(id string, timeout time.Duration) error {
	c, err := m.openContainer(id)
	if err != nil {
		return err
	}
	if c.State() == liblxc.STOPPED {
		return nil
	}
	if err := c.Stop(); err != nil {
		return fmt.Errorf("manager: stop %s: %w", id, err)
	}
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if c.State() == liblxc.STOPPED {
			return nil
		}
		time.Sleep(200 * time.Millisecond)
	}
	return fmt.Errorf("manager: container %s did not stop within %s", id, timeout)
}

// KillContainer sends a signal to the container's init process. For SIGKILL
// it uses lxc-stop --kill; for other signals it sends them directly to the
// container's init PID.
func (m *Manager) KillContainer(id, signal string) error {
	if signal == "" {
		signal = "KILL"
	}

	if signal == "KILL" || signal == "9" || signal == "SIGKILL" {
		out, err := exec.Command("lxc-stop", "--kill", "-n", id, "--lxcpath", m.lxcPath).
			CombinedOutput()
		if err != nil {
			return fmt.Errorf("manager: kill %s: %s: %w", id, out, err)
		}
		return nil
	}

	// For other signals, send directly to the container's init PID.
	c, err := m.openContainer(id)
	if err != nil {
		return err
	}
	pid := c.InitPid()
	if pid < 1 {
		return fmt.Errorf("manager: kill %s: container not running (no init pid)", id)
	}
	out, err := exec.Command("kill", fmt.Sprintf("-%s", signal), fmt.Sprintf("%d", pid)).
		CombinedOutput()
	if err != nil {
		return fmt.Errorf("manager: kill %s (pid %d, signal %s): %s: %w", id, pid, signal, out, err)
	}
	return nil
}

// RemoveContainer destroys a container and removes it from the store.
func (m *Manager) RemoveContainer(id string) error {
	c, err := m.openContainer(id)
	if err != nil {
		return err
	}
	if c.State() == liblxc.RUNNING {
		return fmt.Errorf("manager: cannot remove running container %s; stop it first", id)
	}
	if err := c.Destroy(); err != nil {
		return fmt.Errorf("manager: destroy %s: %w", id, err)
	}
	return m.store.RemoveContainer(id)
}

// RemoveImage destroys the template container and removes the image record.
func (m *Manager) RemoveImage(ref string) error {
	rec := m.store.GetImage(ref)
	if rec == nil {
		return fmt.Errorf("manager: image %q not found", ref)
	}
	if m.containerExists(rec.TemplateName) {
		tmpl, err := liblxc.NewContainer(rec.TemplateName, m.lxcPath)
		if err != nil {
			return err
		}
		if err := tmpl.Destroy(); err != nil {
			return fmt.Errorf("manager: destroy template %s: %w", rec.TemplateName, err)
		}
	}
	return m.store.RemoveImage(ref)
}

// State returns the LXC state string for a container ("running", "stopped", etc.).
func (m *Manager) State(id string) (string, error) {
	c, err := m.openContainer(id)
	if err != nil {
		return "", err
	}
	return strings.ToLower(c.State().String()), nil
}

// Exec runs cmd inside the container using lxc-attach. It returns an
// *exec.Cmd that is not yet started so the caller can wire up stdin/stdout.
func (m *Manager) Exec(id string, cmd []string, env []string) *exec.Cmd {
	args := []string{"-n", id, "--lxcpath", m.lxcPath, "--"}
	args = append(args, cmd...)
	c := exec.Command("lxc-attach", args...)
	c.Env = env
	return c
}

// LogPath returns the console log file path for a container.
func (m *Manager) LogPath(id string) string {
	return LogFilePath(m.lxcPath, id)
}

// LXCPath returns the container storage root.
func (m *Manager) LXCPath() string { return m.lxcPath }

// RootfsPath returns the rootfs path for a container.
func (m *Manager) RootfsPath(id string) string {
	return filepath.Join(m.lxcPath, id, "rootfs")
}

// --- helpers ---

// destroyOrphan removes a cloned container that failed during CreateContainer.
func (m *Manager) destroyOrphan(id string) {
	if c, err := liblxc.NewContainer(id, m.lxcPath); err == nil {
		c.Destroy()
	}
}

func (m *Manager) openContainer(id string) (*liblxc.Container, error) {
	c, err := liblxc.NewContainer(id, m.lxcPath)
	if err != nil {
		return nil, fmt.Errorf("manager: open container %s: %w", id, err)
	}
	return c, nil
}

func (m *Manager) containerExists(name string) bool {
	for _, n := range liblxc.ContainerNames(m.lxcPath) {
		if n == name {
			return true
		}
	}
	return false
}

func waitRunning(c *liblxc.Container, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if c.State() == liblxc.RUNNING {
			return nil
		}
		time.Sleep(200 * time.Millisecond)
	}
	return fmt.Errorf("container %s did not reach RUNNING within %s", c.Name(), timeout)
}

func (m *Manager) runInContainer(c *liblxc.Container, shellCmd string) error {
	out, err := exec.Command(
		"lxc-attach", "-n", c.Name(), "--lxcpath", m.lxcPath,
		"--", "/bin/sh", "-c", shellCmd,
	).CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s: %w", out, err)
	}
	return nil
}

func buildInstallCmd(distro string, packages []string) string {
	pkgs := strings.Join(packages, " ")
	switch distro {
	case "alpine":
		return fmt.Sprintf("apk add --no-cache %s", pkgs)
	case "fedora", "centos", "rockylinux", "almalinux":
		return fmt.Sprintf("dnf install -y %s", pkgs)
	case "archlinux":
		return fmt.Sprintf("pacman -Sy --noconfirm %s", pkgs)
	default: // debian, ubuntu, etc.
		return fmt.Sprintf("apt-get update && apt-get install -y --no-install-recommends %s", pkgs)
	}
}

func imageID(distro, release string) string {
	return distro + "_" + release
}
