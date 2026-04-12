package api

import (
	"archive/tar"
	"bufio"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/games-on-whales/docker-lxc-daemon/internal/image"
	"github.com/games-on-whales/docker-lxc-daemon/internal/lxc"
	"github.com/games-on-whales/docker-lxc-daemon/internal/store"
	"github.com/gorilla/mux"
)

// POST /containers/create
func (h *Handler) createContainer(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if strings.HasPrefix(name, "/") {
		name = name[1:]
	}

	var req ContainerCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		errResponse(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}

	if req.Image == "" {
		errResponse(w, http.StatusBadRequest, "Image is required")
		return
	}

	// Auto-pull if image not present.
	if rec := h.store.GetImage(normalizeImageRef(req.Image)); rec == nil {
		if err := h.mgr.PullImage(req.Image, "amd64", func(_ string) {}); err != nil {
			errResponse(w, http.StatusNotFound,
				fmt.Sprintf("No such image: %s — and pull failed: %s", req.Image, err))
			return
		}
	}

	id := generateID()
	if name == "" {
		name = id[:12]
	}

	// Apply defaults from the image when no explicit Cmd/Entrypoint provided.
	entrypoint := req.Entrypoint
	cmd := req.Cmd
	env := req.Env
	if imgRec := h.store.GetImage(normalizeImageRef(req.Image)); imgRec != nil {
		// OCI image defaults.
		if len(entrypoint) == 0 && len(imgRec.OCIEntrypoint) > 0 {
			entrypoint = imgRec.OCIEntrypoint
		}
		if len(cmd) == 0 && len(imgRec.OCICmd) > 0 {
			cmd = imgRec.OCICmd
		}
		if len(env) == 0 && len(imgRec.OCIEnv) > 0 {
			env = imgRec.OCIEnv
		}
		// App registry defaults (if no OCI config and no user-provided cmd).
		if len(entrypoint) == 0 && len(cmd) == 0 {
			if resolved, err := image.Resolve(imgRec.Ref, "amd64"); err == nil && resolved.App != nil && resolved.App.DefaultCmd != "" {
				cmd = []string{"/bin/sh", "-c", resolved.App.DefaultCmd}
			}
		}
	}

	cfg := lxc.ContainerConfig{
		Entrypoint:  entrypoint,
		Cmd:         cmd,
		Env:         env,
		MemoryBytes: req.HostConfig.Memory,
		CPUShares:   req.HostConfig.CPUShares,
	}

	// Parse bind mounts ("host:container[:ro]")
	for _, bind := range req.HostConfig.Binds {
		parts := strings.SplitN(bind, ":", 3)
		if len(parts) < 2 {
			continue
		}
		m := lxc.MountSpec{
			Source:      parts[0],
			Destination: parts[1],
			ReadOnly:    len(parts) == 3 && parts[2] == "ro",
		}
		cfg.Mounts = append(cfg.Mounts, m)
	}

	// Device mappings
	for _, d := range req.HostConfig.Devices {
		cfg.Devices = append(cfg.Devices, lxc.DeviceSpec{
			PathOnHost:      d.PathOnHost,
			PathInContainer: d.PathInContainer,
		})
	}

	// Persist record before creating so the IP is allocated.
	rec := &store.ContainerRecord{
		ID:      id,
		Name:    name,
		Image:   req.Image,
		ImageID: normalizeImageRef(req.Image),
		Created: time.Now(),
		Entrypoint: entrypoint,
		Cmd:     cmd,
		Env:     env,
		Labels:  req.Labels,
	}
	for _, m := range cfg.Mounts {
		rec.Mounts = append(rec.Mounts, store.MountSpec{
			Source:      m.Source,
			Destination: m.Destination,
			ReadOnly:    m.ReadOnly,
		})
	}
	// Parse port bindings from HostConfig (e.g. "80/tcp" -> [{HostPort:8080, ContainerPort:80, Proto:"tcp"}])
	for containerPortProto, bindings := range req.HostConfig.PortBindings {
		parts := strings.SplitN(containerPortProto, "/", 2)
		cPort, err := strconv.Atoi(parts[0])
		if err != nil {
			continue
		}
		proto := "tcp"
		if len(parts) == 2 && parts[1] != "" {
			proto = parts[1]
		}
		for _, b := range bindings {
			hPort, err := strconv.Atoi(b.HostPort)
			if err != nil {
				continue
			}
			rec.PortBindings = append(rec.PortBindings, store.PortBinding{
				HostPort:      hPort,
				ContainerPort: cPort,
				Proto:         proto,
			})
		}
	}

	if err := h.store.AddContainer(rec); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}

	if err := h.mgr.CreateContainer(id, normalizeImageRef(req.Image), cfg); err != nil {
		h.store.RemoveContainer(id)
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}

	jsonResponse(w, http.StatusCreated, ContainerCreateResponse{
		ID:       id,
		Warnings: []string{},
	})
}

// GET /containers/json
func (h *Handler) listContainers(w http.ResponseWriter, r *http.Request) {
	all := r.URL.Query().Get("all") == "1" || r.URL.Query().Get("all") == "true"
	records := h.store.ListContainers()

	out := make([]ContainerSummary, 0, len(records))
	for _, rec := range records {
		state, _ := h.mgr.State(rec.ID)
		if !all && state != "running" {
			continue
		}
		cmd := strings.Join(append(rec.Entrypoint, rec.Cmd...), " ")
		ports := make([]Port, 0, len(rec.PortBindings))
		for _, pb := range rec.PortBindings {
			ports = append(ports, Port{
				IP:          "0.0.0.0",
				PrivatePort: uint16(pb.ContainerPort),
				PublicPort:  uint16(pb.HostPort),
				Type:        pb.Proto,
			})
		}
		out = append(out, ContainerSummary{
			ID:      rec.ID,
			Names:   []string{"/" + rec.Name},
			Image:   normalizeImageRef(rec.Image),
			ImageID: rec.ImageID,
			Command: cmd,
			Created: rec.Created.Unix(),
			State:   state,
			Status:  stateToStatus(state, rec.Created),
			Ports:   ports,
			Labels:  rec.Labels,
		})
	}
	jsonResponse(w, http.StatusOK, out)
}

// GET /containers/{id}/json
func (h *Handler) inspectContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	rec := h.store.GetContainer(id)
	if rec == nil {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}

	state, _ := h.mgr.State(id)
	running := state == "running"

	resp := ContainerJSON{
		ID:      rec.ID,
		Created: rec.Created.Format(time.RFC3339),
		Name:    "/" + rec.Name,
		State: ContainerState{
			Status:     state,
			Running:    running,
			StartedAt:  rec.Created.Format(time.RFC3339),
			FinishedAt: "0001-01-01T00:00:00Z",
		},
		Image: rec.Image,
		Config: &ContainerConfig{
			Image:      rec.Image,
			Cmd:        rec.Cmd,
			Entrypoint: rec.Entrypoint,
			Env:        rec.Env,
			Labels:     rec.Labels,
		},
		HostConfig: buildHostConfig(rec),
		NetworkSettings: NetworkSettings{
			IPAddress: rec.IPAddress,
			Networks: map[string]EndpointSettings{
				"gow": {
					IPAddress:  rec.IPAddress,
					Gateway:    lxc.BridgeGW,
					NetworkID:  "gow",
				},
			},
		},
	}
	jsonResponse(w, http.StatusOK, resp)
}

// POST /containers/{id}/start
func (h *Handler) startContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	if err := h.mgr.StartContainer(id); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}

	// Set up port forwarding rules after successful start.
	if rec := h.store.GetContainer(id); rec != nil && rec.IPAddress != "" {
		for _, pb := range rec.PortBindings {
			if err := lxc.AddPortForward(rec.IPAddress, pb.HostPort, pb.ContainerPort, pb.Proto); err != nil {
				log.Printf("warning: port forward %d->%s:%d/%s failed: %v",
					pb.HostPort, rec.IPAddress, pb.ContainerPort, pb.Proto, err)
			}
		}
	}

	w.WriteHeader(http.StatusNoContent)
}

// POST /containers/{id}/stop
func (h *Handler) stopContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	if err := h.mgr.StopContainer(id, 10*time.Second); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// POST /containers/{id}/wait
func (h *Handler) waitContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	// Poll until the container stops.
	ctx := r.Context()
	for {
		state, _ := h.mgr.State(id)
		if state != "running" {
			jsonResponse(w, http.StatusOK, map[string]any{
				"StatusCode": 0,
				"Error":      nil,
			})
			return
		}
		select {
		case <-ctx.Done():
			return
		case <-time.After(500 * time.Millisecond):
		}
	}
}

// POST /containers/{id}/kill
func (h *Handler) killContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	signal := r.URL.Query().Get("signal")
	if err := h.mgr.KillContainer(id, signal); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// DELETE /containers/{id}
func (h *Handler) removeContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	force := r.URL.Query().Get("force") == "1" || r.URL.Query().Get("force") == "true"

	// Force: stop the container first if running.
	if force {
		state, _ := h.mgr.State(id)
		if state == "running" {
			h.mgr.StopContainer(id, 5*time.Second)
		}
	}

	// Remove port forwarding rules before destroying the container.
	if rec := h.store.GetContainer(id); rec != nil && rec.IPAddress != "" {
		if err := lxc.RemovePortForwards(rec.IPAddress); err != nil {
			log.Printf("warning: removing port forwards for %s: %v", rec.IPAddress, err)
		}
	}

	if err := h.mgr.RemoveContainer(id); err != nil {
		errResponse(w, http.StatusConflict, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GET /containers/{id}/logs
func (h *Handler) containerLogs(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}

	stdout := r.URL.Query().Get("stdout") == "1" || r.URL.Query().Get("stdout") == "true"
	stderr := r.URL.Query().Get("stderr") == "1" || r.URL.Query().Get("stderr") == "true"
	follow := r.URL.Query().Get("follow") == "1" || r.URL.Query().Get("follow") == "true"

	if !stdout && !stderr {
		stdout = true
		stderr = true
	}

	logPath := h.mgr.LogPath(id)
	f, err := os.Open(logPath)
	if err != nil {
		if os.IsNotExist(err) {
			// No log yet — return empty OK
			w.Header().Set("Content-Type", "application/vnd.docker.raw-stream")
			w.WriteHeader(http.StatusOK)
			return
		}
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer f.Close()

	w.Header().Set("Content-Type", "application/vnd.docker.raw-stream")
	w.WriteHeader(http.StatusOK)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Bytes()
		writeLogFrame(w, 1, append(line, '\n')) // treat all console output as stdout
	}

	if follow {
		// Tail: poll for new content until client disconnects.
		ctx := r.Context()
		for {
			select {
			case <-ctx.Done():
				return
			case <-time.After(200 * time.Millisecond):
			}
			buf := make([]byte, 32*1024)
			n, err := f.Read(buf)
			if n > 0 {
				writeLogFrame(w, 1, buf[:n])
				if fl, ok := w.(http.Flusher); ok {
					fl.Flush()
				}
			}
			if err == io.EOF {
				continue
			}
			if err != nil {
				return
			}
		}
	}
}

// POST /containers/{id}/restart
func (h *Handler) restartContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	state, _ := h.mgr.State(id)
	if state == "running" {
		if err := h.mgr.StopContainer(id, 10*time.Second); err != nil {
			errResponse(w, http.StatusInternalServerError, err.Error())
			return
		}
	}
	if err := h.mgr.StartContainer(id); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// POST /containers/{id}/rename
func (h *Handler) renameContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	newName := r.URL.Query().Get("name")
	if newName == "" {
		errResponse(w, http.StatusBadRequest, "name is required")
		return
	}
	newName = strings.TrimPrefix(newName, "/")
	rec := h.store.GetContainer(id)
	if rec == nil {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	rec.Name = newName
	if err := h.store.AddContainer(rec); err != nil {
		errResponse(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GET /containers/{id}/top
func (h *Handler) topContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	state, _ := h.mgr.State(id)
	if state != "running" {
		errResponse(w, http.StatusConflict, "container is not running")
		return
	}
	cmd := h.mgr.Exec(id, []string{"ps", "-eo", "pid,user,time,comm"}, nil)
	out, err := cmd.Output()
	if err != nil {
		errResponse(w, http.StatusInternalServerError, fmt.Sprintf("ps: %v", err))
		return
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	titles := []string{"PID", "USER", "TIME", "COMMAND"}
	processes := make([][]string, 0, len(lines)-1)
	for _, line := range lines[1:] {
		fields := strings.Fields(line)
		if len(fields) >= 4 {
			processes = append(processes, fields[:4])
		}
	}
	jsonResponse(w, http.StatusOK, map[string]any{
		"Titles":    titles,
		"Processes": processes,
	})
}

// POST /containers/{id}/attach
func (h *Handler) attachContainer(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}

	hj, ok := w.(http.Hijacker)
	if !ok {
		errResponse(w, http.StatusInternalServerError, "streaming not supported")
		return
	}
	conn, buf, err := hj.Hijack()
	if err != nil {
		return
	}
	defer conn.Close()

	buf.WriteString("HTTP/1.1 101 UPGRADED\r\n")
	buf.WriteString("Content-Type: application/vnd.docker.raw-stream\r\n")
	buf.WriteString("Connection: Upgrade\r\n")
	buf.WriteString("Upgrade: tcp\r\n")
	buf.WriteString("\r\n")
	buf.Flush()

	cmd := h.mgr.Exec(id, []string{"/bin/sh"}, nil)
	runExecTTY(cmd, conn)
}

// safeJoin joins base and untrusted path, returning an error if the result
// escapes base. Prevents path traversal attacks in docker cp.
func safeJoin(base, untrusted string) (string, error) {
	target := filepath.Join(base, filepath.Clean("/"+untrusted))
	if !strings.HasPrefix(target, filepath.Clean(base)+string(os.PathSeparator)) && target != filepath.Clean(base) {
		return "", fmt.Errorf("path %q escapes rootfs", untrusted)
	}
	return target, nil
}

// PUT /containers/{id}/archive — docker cp TO container
func (h *Handler) putArchive(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	destPath := r.URL.Query().Get("path")
	if destPath == "" {
		errResponse(w, http.StatusBadRequest, "path is required")
		return
	}
	rootfs := h.mgr.RootfsPath(id)
	dest, err := safeJoin(rootfs, destPath)
	if err != nil {
		errResponse(w, http.StatusForbidden, err.Error())
		return
	}

	tr := tar.NewReader(r.Body)
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			errResponse(w, http.StatusInternalServerError, err.Error())
			return
		}
		// Reject symlinks — they can be used to escape the rootfs.
		if hdr.Typeflag == tar.TypeSymlink || hdr.Typeflag == tar.TypeLink {
			continue
		}
		target, err := safeJoin(dest, hdr.Name)
		if err != nil {
			errResponse(w, http.StatusForbidden, err.Error())
			return
		}
		switch hdr.Typeflag {
		case tar.TypeDir:
			if err := os.MkdirAll(target, os.FileMode(hdr.Mode)); err != nil {
				errResponse(w, http.StatusInternalServerError, err.Error())
				return
			}
		case tar.TypeReg:
			if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
				errResponse(w, http.StatusInternalServerError, err.Error())
				return
			}
			f, err := os.OpenFile(target, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, os.FileMode(hdr.Mode))
			if err != nil {
				errResponse(w, http.StatusInternalServerError, err.Error())
				return
			}
			if _, err := io.Copy(f, tr); err != nil {
				f.Close()
				errResponse(w, http.StatusInternalServerError, err.Error())
				return
			}
			f.Close()
		}
	}
	w.WriteHeader(http.StatusOK)
}

// GET /containers/{id}/archive — docker cp FROM container
func (h *Handler) getArchive(w http.ResponseWriter, r *http.Request) {
	id := h.resolveID(mux.Vars(r)["id"])
	if id == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}
	srcPath := r.URL.Query().Get("path")
	if srcPath == "" {
		errResponse(w, http.StatusBadRequest, "path is required")
		return
	}
	rootfs := h.mgr.RootfsPath(id)
	src, err := safeJoin(rootfs, srcPath)
	if err != nil {
		errResponse(w, http.StatusForbidden, err.Error())
		return
	}

	// Use Lstat to detect symlinks without following them.
	info, err := os.Lstat(src)
	if err != nil {
		errResponse(w, http.StatusNotFound, fmt.Sprintf("no such file: %s", srcPath))
		return
	}
	if info.Mode()&os.ModeSymlink != 0 {
		errResponse(w, http.StatusForbidden, "refusing to follow symlink")
		return
	}

	// Docker CLI requires X-Docker-Container-Path-Stat header.
	stat := map[string]any{
		"name":       info.Name(),
		"size":       info.Size(),
		"mode":       info.Mode(),
		"mtime":      info.ModTime().Format(time.RFC3339),
		"linkTarget": "",
	}
	statJSON, _ := json.Marshal(stat)
	w.Header().Set("X-Docker-Container-Path-Stat", base64.StdEncoding.EncodeToString(statJSON))
	w.Header().Set("Content-Type", "application/x-tar")
	w.WriteHeader(http.StatusOK)
	tw := tar.NewWriter(w)
	defer tw.Close()

	if !info.IsDir() {
		tw.WriteHeader(&tar.Header{
			Name: filepath.Base(srcPath),
			Size: info.Size(),
			Mode: int64(info.Mode()),
		})
		f, err := os.Open(src)
		if err != nil {
			return
		}
		io.Copy(tw, f)
		f.Close()
		return
	}

	filepath.WalkDir(src, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		// Skip symlinks to prevent escape.
		if d.Type()&os.ModeSymlink != 0 {
			return nil
		}
		fi, err := d.Info()
		if err != nil {
			return nil
		}
		rel, _ := filepath.Rel(src, path)
		hdr, _ := tar.FileInfoHeader(fi, "")
		hdr.Name = rel
		tw.WriteHeader(hdr)
		if !d.IsDir() {
			f, err := os.Open(path)
			if err != nil {
				return nil
			}
			io.Copy(tw, f)
			f.Close()
		}
		return nil
	})
}

// writeLogFrame writes a single Docker multiplexed stream frame.
// streamType: 1=stdout, 2=stderr.
func writeLogFrame(w io.Writer, streamType byte, data []byte) {
	header := make([]byte, 8)
	header[0] = streamType
	binary.BigEndian.PutUint32(header[4:], uint32(len(data)))
	w.Write(header)
	w.Write(data)
}

// stateToStatus returns a human-readable status string like Docker's "Up 2 hours".
func stateToStatus(state string, created time.Time) string {
	switch state {
	case "running":
		return "Up " + humanDuration(time.Since(created))
	case "stopped":
		return "Exited (0) " + humanDuration(time.Since(created)) + " ago"
	default:
		return state
	}
}

func humanDuration(d time.Duration) string {
	switch {
	case d < time.Minute:
		return fmt.Sprintf("%d seconds", int(d.Seconds()))
	case d < time.Hour:
		return fmt.Sprintf("%d minutes", int(d.Minutes()))
	case d < 24*time.Hour:
		return fmt.Sprintf("%d hours", int(d.Hours()))
	default:
		return fmt.Sprintf("%d days", int(d.Hours()/24))
	}
}

func (h *Handler) resolveID(idOrName string) string {
	return h.store.ResolveID(idOrName)
}

// buildHostConfig reconstructs a HostConfig from the stored container record.
func buildHostConfig(rec *store.ContainerRecord) *HostConfig {
	hc := &HostConfig{}
	if len(rec.PortBindings) > 0 {
		hc.PortBindings = make(map[string][]PortBinding)
		for _, pb := range rec.PortBindings {
			key := fmt.Sprintf("%d/%s", pb.ContainerPort, pb.Proto)
			hc.PortBindings[key] = append(hc.PortBindings[key], PortBinding{
				HostIP:   "0.0.0.0",
				HostPort: strconv.Itoa(pb.HostPort),
			})
		}
	}
	for _, m := range rec.Mounts {
		bind := m.Source + ":" + m.Destination
		if m.ReadOnly {
			bind += ":ro"
		}
		hc.Binds = append(hc.Binds, bind)
	}
	return hc
}
