// Package store persists metadata for containers and images managed by this
// daemon. LXC itself has no concept of Docker-specific metadata (image name,
// environment variables, port bindings, etc.), so we maintain a JSON file
// alongside the LXC state directory.
package store

import (
	"encoding/json"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

const defaultPath = "/var/lib/docker-lxc-daemon"

// ContainerRecord holds Docker-layer metadata for a single container.
type ContainerRecord struct {
	ID         string            `json:"id"`          // LXC container name, doubles as Docker short ID
	Name       string            `json:"name"`        // Docker-style name (no leading slash)
	Image      string            `json:"image"`       // Original image:tag as requested
	ImageID    string            `json:"image_id"`    // Resolved image identifier
	Created    time.Time         `json:"created"`
	Entrypoint []string          `json:"entrypoint"`
	Cmd        []string          `json:"cmd"`
	Env        []string          `json:"env"`
	Labels     map[string]string `json:"labels"`
	IPAddress    string            `json:"ip_address"`
	PortBindings []PortBinding    `json:"port_bindings,omitempty"`
	Mounts       []MountSpec      `json:"mounts"`
}

// PortBinding records a single host→container port mapping.
type PortBinding struct {
	HostPort      int    `json:"host_port"`
	ContainerPort int    `json:"container_port"`
	Proto         string `json:"proto"` // "tcp" or "udp"
}

// MountSpec mirrors the relevant fields of a Docker bind mount.
type MountSpec struct {
	Source      string `json:"source"`
	Destination string `json:"destination"`
	ReadOnly    bool   `json:"read_only"`
}

// ImageRecord holds metadata for a pulled image (backed by an LXC template
// container named __template_<ID>).
type ImageRecord struct {
	ID           string    `json:"id"`            // e.g. "ubuntu_22.04"
	Ref          string    `json:"ref"`           // original "ubuntu:22.04"
	Distro       string    `json:"distro"`        // "ubuntu"
	Release      string    `json:"release"`       // "jammy"
	Arch         string    `json:"arch"`          // "amd64"
	TemplateName string    `json:"template_name"` // LXC container used as clone source
	Created      time.Time `json:"created"`
}

type state struct {
	Containers map[string]*ContainerRecord `json:"containers"` // keyed by ID
	Images     map[string]*ImageRecord     `json:"images"`     // keyed by Ref (e.g. "ubuntu:22.04")
	NextIP     int                         `json:"next_ip"`    // last octet of 10.100.0.x, starts at 2
	FreeIPs    []int                       `json:"free_ips"`   // last octets of freed IPs available for reuse
}

// Store is a thread-safe, file-backed metadata store.
type Store struct {
	mu   sync.RWMutex
	path string
	data state
}

// New opens (or creates) the store at the default path.
func New() (*Store, error) {
	return NewAt(defaultPath)
}

// NewAt opens (or creates) the store rooted at dir.
func NewAt(dir string) (*Store, error) {
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return nil, fmt.Errorf("store: mkdir %s: %w", dir, err)
	}

	s := &Store{
		path: filepath.Join(dir, "state.json"),
		data: state{
			Containers: make(map[string]*ContainerRecord),
			Images:     make(map[string]*ImageRecord),
			NextIP:     2,
		},
	}

	if err := s.load(); err != nil && !os.IsNotExist(err) {
		return nil, fmt.Errorf("store: load: %w", err)
	}
	return s, nil
}

// AllocateIP returns the next available IP in the 10.100.0.0/24 range.
// Freed IPs are reused first; otherwise the counter advances.
func (s *Store) AllocateIP() (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	var octet int
	if len(s.data.FreeIPs) > 0 {
		octet = s.data.FreeIPs[0]
		s.data.FreeIPs = s.data.FreeIPs[1:]
	} else {
		if s.data.NextIP > 254 {
			return "", fmt.Errorf("store: IP space exhausted")
		}
		octet = s.data.NextIP
		s.data.NextIP++
	}
	ip := fmt.Sprintf("10.100.0.%d", octet)
	return ip, s.save()
}

// FreeIP returns an IP address to the pool for reuse.
func (s *Store) FreeIP(ip string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	parts := strings.Split(ip, ".")
	if len(parts) == 4 {
		if octet, err := strconv.Atoi(parts[3]); err == nil && octet >= 2 {
			s.data.FreeIPs = append(s.data.FreeIPs, octet)
			s.save()
		}
	}
}

// AddContainer persists a new container record.
func (s *Store) AddContainer(r *ContainerRecord) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.data.Containers[r.ID] = r
	return s.save()
}

// RemoveContainer deletes a container record by ID and frees its IP address.
func (s *Store) RemoveContainer(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if rec, ok := s.data.Containers[id]; ok && rec.IPAddress != "" {
		if ip := net.ParseIP(rec.IPAddress); ip != nil {
			parts := strings.Split(rec.IPAddress, ".")
			if len(parts) == 4 {
				if octet, err := strconv.Atoi(parts[3]); err == nil && octet >= 2 {
					s.data.FreeIPs = append(s.data.FreeIPs, octet)
				}
			}
		}
	}

	delete(s.data.Containers, id)
	return s.save()
}

// GetContainer returns the record for id, or nil if not found.
func (s *Store) GetContainer(id string) *ContainerRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.data.Containers[id]
}

// FindContainerByName returns the first container whose Name matches.
func (s *Store) FindContainerByName(name string) *ContainerRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for _, r := range s.data.Containers {
		if r.Name == name {
			return r
		}
	}
	return nil
}

// ListContainers returns all container records.
func (s *Store) ListContainers() []*ContainerRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]*ContainerRecord, 0, len(s.data.Containers))
	for _, r := range s.data.Containers {
		out = append(out, r)
	}
	return out
}

// AddImage persists a new image record keyed by its Ref.
func (s *Store) AddImage(r *ImageRecord) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.data.Images[r.Ref] = r
	return s.save()
}

// RemoveImage deletes an image record by Ref.
func (s *Store) RemoveImage(ref string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.data.Images, ref)
	return s.save()
}

// GetImage returns the image record for ref, or nil if not found.
// It tries an exact match first, then falls back to matching after
// stripping registry and "library/" prefixes (e.g. "nginx:latest"
// matches "docker.io/library/nginx:latest").
func (s *Store) GetImage(ref string) *ImageRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if r, ok := s.data.Images[ref]; ok {
		return r
	}
	// Fuzzy match: strip prefixes from both sides and compare.
	bare := bareImageRef(ref)
	for key, r := range s.data.Images {
		if bareImageRef(key) == bare {
			return r
		}
	}
	return nil
}

// bareImageRef strips registry and "library/" prefixes from an image ref.
// "docker.io/library/nginx:latest" → "nginx:latest"
// "nginx:latest" → "nginx:latest"
func bareImageRef(ref string) string {
	// Strip registry (anything with a dot before the first slash).
	if i := strings.Index(ref, "/"); i != -1 {
		prefix := ref[:i]
		if strings.Contains(prefix, ".") || strings.Contains(prefix, ":") {
			ref = ref[i+1:]
		}
	}
	// Strip "library/" prefix (Docker Hub default namespace).
	ref = strings.TrimPrefix(ref, "library/")
	return ref
}

// ListImages returns all image records.
func (s *Store) ListImages() []*ImageRecord {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]*ImageRecord, 0, len(s.data.Images))
	for _, r := range s.data.Images {
		out = append(out, r)
	}
	return out
}

// ResolveID resolves a partial or full container ID or name to a full ID.
// Returns "" if not found.
func (s *Store) ResolveID(idOrName string) string {
	s.mu.RLock()
	defer s.mu.RUnlock()

	// Exact ID match
	if _, ok := s.data.Containers[idOrName]; ok {
		return idOrName
	}
	// Prefix match on ID
	for id := range s.data.Containers {
		if len(idOrName) >= 4 && len(id) >= len(idOrName) && id[:len(idOrName)] == idOrName {
			return id
		}
	}
	// Name match
	for id, r := range s.data.Containers {
		if r.Name == idOrName {
			return id
		}
	}
	return ""
}

func (s *Store) load() error {
	f, err := os.Open(s.path)
	if err != nil {
		return err
	}
	defer f.Close()
	return json.NewDecoder(f).Decode(&s.data)
}

func (s *Store) save() error {
	tmp := s.path + ".tmp"
	f, err := os.OpenFile(tmp, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o600)
	if err != nil {
		return err
	}
	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	if err := enc.Encode(&s.data); err != nil {
		f.Close()
		return err
	}
	if err := f.Close(); err != nil {
		return err
	}
	return os.Rename(tmp, s.path)
}
