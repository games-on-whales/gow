package api

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os/exec"
	"sync"
	"time"

	"github.com/creack/pty"
	"github.com/gorilla/mux"
)

// execStore holds in-flight and completed exec instances.
type execStore struct {
	mu      sync.RWMutex
	records map[string]*execRecord
}

func newExecStore() *execStore {
	return &execStore{records: make(map[string]*execRecord)}
}

func (s *execStore) add(r *execRecord) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.records[r.ID] = r
}

func (s *execStore) get(id string) *execRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.records[id]
}

func (s *execStore) update(id string, fn func(*execRecord)) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if r, ok := s.records[id]; ok {
		fn(r)
	}
}

// prune removes completed exec records older than 5 minutes.
func (s *execStore) prune() {
	s.mu.Lock()
	defer s.mu.Unlock()
	cutoff := time.Now().Add(-5 * time.Minute)
	for id, r := range s.records {
		if !r.Running && r.StartedAt.Before(cutoff) {
			delete(s.records, id)
		}
	}
}

// POST /containers/{id}/exec
func (h *Handler) execCreate(w http.ResponseWriter, r *http.Request) {
	containerID := h.resolveID(mux.Vars(r)["id"])
	if containerID == "" {
		errResponse(w, http.StatusNotFound, "No such container")
		return
	}

	var req ExecCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		errResponse(w, http.StatusBadRequest, err.Error())
		return
	}

	if len(req.Cmd) == 0 {
		errResponse(w, http.StatusBadRequest, "Cmd is required")
		return
	}

	rec := &execRecord{
		ID:          generateID(),
		ContainerID: containerID,
		Cmd:         req.Cmd,
		Tty:         req.Tty,
		Env:         req.Env,
	}
	h.execs.add(rec)

	jsonResponse(w, http.StatusCreated, ExecCreateResponse{ID: rec.ID})
}

// POST /exec/{id}/start
func (h *Handler) execStart(w http.ResponseWriter, r *http.Request) {
	execID := mux.Vars(r)["id"]
	rec := h.execs.get(execID)
	if rec == nil {
		errResponse(w, http.StatusNotFound, "No such exec instance")
		return
	}

	var req ExecStartRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		errResponse(w, http.StatusBadRequest, err.Error())
		return
	}

	if req.Detach {
		// Fire-and-forget: run the command, don't stream output.
		cmd := h.mgr.Exec(rec.ContainerID, rec.Cmd, rec.Env)
		go func() {
			err := cmd.Run()
			code := 0
			if err != nil {
				if ee, ok := err.(*exec.ExitError); ok {
					code = ee.ExitCode()
				}
			}
			h.execs.update(rec.ID, func(r *execRecord) {
				r.Running = false
				r.ExitCode = code
			})
		}()
		w.WriteHeader(http.StatusNoContent)
		return
	}

	// Hijack the connection for streaming.
	hj, ok := w.(http.Hijacker)
	if !ok {
		errResponse(w, http.StatusInternalServerError, "streaming not supported")
		return
	}
	conn, buf, err := hj.Hijack()
	if err != nil {
		return
	}
	// conn is closed by runExecTTY/runExecMux or deferred below for non-TTY.
	closeConn := true
	defer func() {
		if closeConn {
			conn.Close()
		}
	}()

	// Write HTTP response preamble manually.
	buf.WriteString("HTTP/1.1 101 UPGRADED\r\n")
	buf.WriteString("Content-Type: application/vnd.docker.raw-stream\r\n")
	buf.WriteString("Connection: Upgrade\r\n")
	buf.WriteString("Upgrade: tcp\r\n")
	buf.WriteString("\r\n")
	buf.Flush()

	h.execs.update(rec.ID, func(r *execRecord) { r.Running = true; r.StartedAt = time.Now() })

	cmd := h.mgr.Exec(rec.ContainerID, rec.Cmd, rec.Env)

	if rec.Tty {
		closeConn = false // runExecTTY closes conn itself
		runExecTTY(cmd, conn)
	} else {
		runExecMux(cmd, conn)
	}

	code := 0
	if cmd.ProcessState != nil {
		code = cmd.ProcessState.ExitCode()
	}
	h.execs.update(rec.ID, func(r *execRecord) {
		r.Running = false
		r.ExitCode = code
	})
}

// GET /exec/{id}/json
func (h *Handler) execInspect(w http.ResponseWriter, r *http.Request) {
	execID := mux.Vars(r)["id"]
	rec := h.execs.get(execID)
	if rec == nil {
		errResponse(w, http.StatusNotFound, "No such exec instance")
		return
	}

	entrypoint := ""
	args := []string{}
	if len(rec.Cmd) > 0 {
		entrypoint = rec.Cmd[0]
		args = rec.Cmd[1:]
	}

	jsonResponse(w, http.StatusOK, ExecInspect{
		ID:          rec.ID,
		ContainerID: rec.ContainerID,
		Running:     rec.Running,
		ExitCode:    rec.ExitCode,
		ProcessConfig: ExecProcessConfig{
			Tty:        rec.Tty,
			Entrypoint: entrypoint,
			Arguments:  args,
		},
	})
}

// runExecTTY runs cmd with a PTY attached and proxies raw bytes between the
// PTY master and the hijacked connection. Used when Tty=true.
func runExecTTY(cmd *exec.Cmd, conn io.ReadWriter) {
	ptmx, err := pty.Start(cmd)
	if err != nil {
		fmt.Fprintf(conn, "error starting pty: %s\n", err)
		return
	}

	var wg sync.WaitGroup
	wg.Add(2)

	// PTY → connection
	go func() {
		defer wg.Done()
		io.Copy(conn, ptmx)
	}()

	// connection → PTY (stdin)
	go func() {
		defer wg.Done()
		io.Copy(ptmx, conn)
	}()

	cmd.Wait()
	// Close the PTY master to unblock the io.Copy goroutines. If we defer
	// this, wg.Wait below deadlocks because the copies never see EOF.
	ptmx.Close()
	// Close the connection's read side so the stdin copy also returns.
	if c, ok := conn.(io.Closer); ok {
		c.Close()
	}
	wg.Wait()
}

// runExecMux runs cmd with pipes and multiplexes stdout/stderr into the
// Docker raw-stream format. Used when Tty=false.
func runExecMux(cmd *exec.Cmd, conn io.ReadWriter) {
	stdoutR, stdoutW := io.Pipe()
	stderrR, stderrW := io.Pipe()
	cmd.Stdout = stdoutW
	cmd.Stderr = stderrW

	if err := cmd.Start(); err != nil {
		writeLogFrame(conn, 2, []byte("error: "+err.Error()+"\n"))
		return
	}

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		b := make([]byte, 32*1024)
		for {
			n, err := stdoutR.Read(b)
			if n > 0 {
				writeLogFrame(conn, 1, b[:n])
			}
			if err != nil {
				return
			}
		}
	}()

	go func() {
		defer wg.Done()
		b := make([]byte, 32*1024)
		for {
			n, err := stderrR.Read(b)
			if n > 0 {
				writeLogFrame(conn, 2, b[:n])
			}
			if err != nil {
				return
			}
		}
	}()

	cmd.Wait()
	// Close pipe writers to unblock the reader goroutines.
	stdoutW.Close()
	stderrW.Close()
	wg.Wait()
}

// generateID returns a 64-character hex ID matching Docker's container ID length.
func generateID() string {
	b := make([]byte, 32)
	rand.Read(b)
	return fmt.Sprintf("%x", b)
}
