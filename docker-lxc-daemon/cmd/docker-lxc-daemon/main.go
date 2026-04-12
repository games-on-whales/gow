package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/games-on-whales/docker-lxc-daemon/internal/api"
	"github.com/games-on-whales/docker-lxc-daemon/internal/lxc"
	"github.com/games-on-whales/docker-lxc-daemon/internal/store"
)

func main() {
	socketPath := flag.String("socket", "/var/run/docker.sock", "Unix socket path to listen on")
	lxcPath := flag.String("lxcpath", "/var/lib/lxc", "LXC container storage path")
	statePath := flag.String("statepath", "/var/lib/docker-lxc-daemon", "Daemon state directory")
	flag.Parse()

	if os.Geteuid() != 0 {
		log.Fatal("docker-lxc-daemon must run as root")
	}

	st, err := store.NewAt(*statePath)
	if err != nil {
		log.Fatalf("store: %v", err)
	}

	mgr, err := lxc.NewManager(*lxcPath, st)
	if err != nil {
		log.Fatalf("manager: %v", err)
	}

	handler := api.NewHandler(mgr, st)

	// Remove stale socket if present.
	os.Remove(*socketPath)

	l, err := net.Listen("unix", *socketPath)
	if err != nil {
		log.Fatalf("listen %s: %v", *socketPath, err)
	}
	// Docker clients expect the socket to be world-writable (group docker
	// restricts access in production; for GoW we keep it simple).
	if err := os.Chmod(*socketPath, 0o666); err != nil {
		log.Printf("warning: chmod socket: %v", err)
	}

	srv := &http.Server{Handler: handler}

	// Graceful shutdown on SIGTERM/SIGINT.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	go func() {
		<-ctx.Done()
		log.Println("shutting down")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		srv.Shutdown(shutdownCtx)
		lxc.TeardownBridge()
	}()

	fmt.Printf("docker-lxc-daemon listening on %s\n", *socketPath)
	if err := srv.Serve(l); err != nil && err != http.ErrServerClosed {
		log.Fatalf("serve: %v", err)
	}
}
