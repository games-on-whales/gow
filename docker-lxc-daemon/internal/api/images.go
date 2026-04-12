package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
)

// GET /images/json
func (h *Handler) listImages(w http.ResponseWriter, r *http.Request) {
	records := h.store.ListImages()
	out := make([]ImageSummary, 0, len(records))
	for _, rec := range records {
		out = append(out, ImageSummary{
			ID:       "sha256:" + rec.ID,
			RepoTags: []string{rec.Ref},
			Created:  rec.Created.Unix(),
			Labels:   map[string]string{},
		})
	}
	jsonResponse(w, http.StatusOK, out)
}

// POST /images/create  (docker pull)
// Query params: fromImage=<name>, tag=<tag>
func (h *Handler) pullImage(w http.ResponseWriter, r *http.Request) {
	fromImage := r.URL.Query().Get("fromImage")
	tag := r.URL.Query().Get("tag")
	if tag == "" {
		tag = "latest"
	}

	ref := fromImage
	if !strings.Contains(fromImage, ":") {
		ref = fromImage + ":" + tag
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	enc := json.NewEncoder(w)
	send := func(status string) {
		enc.Encode(map[string]string{"status": status})
		if f, ok := w.(http.Flusher); ok {
			f.Flush()
		}
	}

	send(fmt.Sprintf("Pulling from %s", fromImage))

	err := h.mgr.PullImage(ref, "amd64", func(msg string) {
		send(msg)
	})
	if err != nil {
		send(fmt.Sprintf("Error: %s", err))
		return
	}

	send(fmt.Sprintf("Status: Downloaded newer image for %s", ref))
}

// GET /images/{name}/json  (docker image inspect)
func (h *Handler) inspectImage(w http.ResponseWriter, r *http.Request) {
	name := mux.Vars(r)["name"]
	rec := h.store.GetImage(normalizeImageRef(name))
	if rec == nil {
		errResponse(w, http.StatusNotFound, fmt.Sprintf("No such image: %s", name))
		return
	}
	jsonResponse(w, http.StatusOK, ImageInspect{
		ID:           "sha256:" + rec.ID,
		RepoTags:     []string{rec.Ref},
		Created:      rec.Created.Format(time.RFC3339),
		Architecture: rec.Arch,
		Os:           "linux",
		Labels:       map[string]string{},
	})
}

// DELETE /images/{name}  (docker rmi)
func (h *Handler) removeImage(w http.ResponseWriter, r *http.Request) {
	name := mux.Vars(r)["name"]
	ref := normalizeImageRef(name)
	if err := h.mgr.RemoveImage(ref); err != nil {
		errResponse(w, http.StatusConflict, err.Error())
		return
	}
	jsonResponse(w, http.StatusOK, []map[string]string{
		{"Untagged": ref},
	})
}

func normalizeImageRef(name string) string {
	if !strings.Contains(name, ":") {
		return name + ":latest"
	}
	return name
}
