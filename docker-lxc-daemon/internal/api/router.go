package api

import (
	"net/http"
	"time"

	"github.com/games-on-whales/docker-lxc-daemon/internal/lxc"
	"github.com/games-on-whales/docker-lxc-daemon/internal/store"
	"github.com/gorilla/mux"
)

// Handler is the root HTTP handler. It holds references to the LXC manager
// and the metadata store, and owns the in-memory exec instance table.
type Handler struct {
	mgr   *lxc.Manager
	store *store.Store
	execs *execStore
}

// NewHandler wires up the Handler and returns an http.Handler ready to serve.
func NewHandler(mgr *lxc.Manager, st *store.Store) http.Handler {
	h := &Handler{
		mgr:   mgr,
		store: st,
		execs: newExecStore(),
	}
	// Periodically prune completed exec records to prevent memory leaks.
	go func() {
		for {
			time.Sleep(60 * time.Second)
			h.execs.prune()
		}
	}()
	return h.routes()
}

func (h *Handler) routes() http.Handler {
	r := mux.NewRouter()

	// Docker clients prefix all paths with /v<version>/. We accept any version
	// prefix by using a subrouter that strips it, and also mount the bare paths
	// so that clients that omit the version still work.
	api := r.PathPrefix("/v{version:[0-9.]+}").Subrouter()

	for _, sub := range []*mux.Router{r, api} {
		// System
		sub.HandleFunc("/_ping", h.ping).Methods(http.MethodGet, http.MethodHead)
		sub.HandleFunc("/version", h.version).Methods(http.MethodGet)
		sub.HandleFunc("/info", h.info).Methods(http.MethodGet)

		// Containers
		sub.HandleFunc("/containers/json", h.listContainers).Methods(http.MethodGet)
		sub.HandleFunc("/containers/create", h.createContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/json", h.inspectContainer).Methods(http.MethodGet)
		sub.HandleFunc("/containers/{id}/start", h.startContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/stop", h.stopContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/kill", h.killContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/wait", h.waitContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/restart", h.restartContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/rename", h.renameContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/top", h.topContainer).Methods(http.MethodGet)
		sub.HandleFunc("/containers/{id}/attach", h.attachContainer).Methods(http.MethodPost)
		sub.HandleFunc("/containers/{id}/logs", h.containerLogs).Methods(http.MethodGet)
		sub.HandleFunc("/containers/{id}/archive", h.putArchive).Methods(http.MethodPut)
		sub.HandleFunc("/containers/{id}/archive", h.getArchive).Methods(http.MethodGet, http.MethodHead)
		sub.HandleFunc("/containers/{id}", h.removeContainer).Methods(http.MethodDelete)

		// Images
		sub.HandleFunc("/images/json", h.listImages).Methods(http.MethodGet)
		sub.HandleFunc("/images/create", h.pullImage).Methods(http.MethodPost)
		sub.HandleFunc("/images/{name:.*}/json", h.inspectImage).Methods(http.MethodGet)
		sub.HandleFunc("/images/{name:.*}", h.removeImage).Methods(http.MethodDelete)

		// Exec
		sub.HandleFunc("/containers/{id}/exec", h.execCreate).Methods(http.MethodPost)
		sub.HandleFunc("/exec/{id}/start", h.execStart).Methods(http.MethodPost)
		sub.HandleFunc("/exec/{id}/json", h.execInspect).Methods(http.MethodGet)
	}

	return r
}
