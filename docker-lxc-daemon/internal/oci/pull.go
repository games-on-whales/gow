// Package oci handles pulling and unpacking OCI/Docker images using skopeo
// and umoci. This is the fallback path for images that are not known distro
// or app images in the built-in registry.
package oci

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// ImageConfig holds the fields extracted from an OCI image configuration
// that are needed to run a container.
type ImageConfig struct {
	Entrypoint []string
	Cmd        []string
	Env        []string
	WorkingDir string
	Ports      []string // e.g. ["80/tcp", "443/tcp"]
}

// Pull downloads an OCI image from a registry and unpacks it to a rootfs
// directory. It returns the extracted image config and the path to the rootfs.
//
// storeDir is the base directory for OCI storage (e.g. /var/lib/docker-lxc-daemon/oci).
// ref is the image reference (e.g. "nginx:latest", "ghcr.io/org/app:v1").
// progress is called with status messages.
func Pull(storeDir, ref string, progress func(string)) (*ImageConfig, string, error) {
	if err := os.MkdirAll(storeDir, 0o755); err != nil {
		return nil, "", fmt.Errorf("oci: mkdir %s: %w", storeDir, err)
	}

	// Normalize ref: add docker.io/library/ prefix if bare name.
	dockerRef := normalizeDockerRef(ref)
	safeName := SafeDirName(ref)

	ociDir := filepath.Join(storeDir, "images", safeName)
	bundleDir := filepath.Join(storeDir, "bundles", safeName)
	tag := tagFromRef(ref)

	// 1. Pull image via skopeo.
	progress(fmt.Sprintf("Pulling OCI image %s", dockerRef))
	if err := os.MkdirAll(filepath.Dir(ociDir), 0o755); err != nil {
		return nil, "", err
	}
	// Remove stale OCI dir if exists (re-pull).
	os.RemoveAll(ociDir)

	skopeoArgs := []string{
		"copy",
		"docker://" + dockerRef,
		"oci:" + ociDir + ":" + tag,
	}
	out, err := exec.Command("skopeo", skopeoArgs...).CombinedOutput()
	if err != nil {
		return nil, "", fmt.Errorf("oci: skopeo copy: %s: %w", out, err)
	}

	// 2. Parse image config from OCI layout.
	progress("Extracting image config")
	cfg, err := parseImageConfig(ociDir, tag)
	if err != nil {
		return nil, "", fmt.Errorf("oci: parse config: %w", err)
	}

	// 3. Unpack to rootfs via umoci.
	progress("Unpacking image layers")
	os.RemoveAll(bundleDir)
	umociArgs := []string{
		"unpack",
		"--image", ociDir + ":" + tag,
		bundleDir,
	}
	out, err = exec.Command("umoci", umociArgs...).CombinedOutput()
	if err != nil {
		return nil, "", fmt.Errorf("oci: umoci unpack: %s: %w", out, err)
	}

	rootfs := filepath.Join(bundleDir, "rootfs")
	if _, err := os.Stat(rootfs); err != nil {
		return nil, "", fmt.Errorf("oci: rootfs not found at %s", rootfs)
	}

	return cfg, rootfs, nil
}

// Cleanup removes the OCI layout and bundle for a given image ref.
func Cleanup(storeDir, ref string) {
	safeName := SafeDirName(ref)
	os.RemoveAll(filepath.Join(storeDir, "images", safeName))
	os.RemoveAll(filepath.Join(storeDir, "bundles", safeName))
}

// parseImageConfig reads the OCI image layout and extracts the image config.
func parseImageConfig(ociDir, tag string) (*ImageConfig, error) {
	// Read index.json to find the manifest.
	indexPath := filepath.Join(ociDir, "index.json")
	indexData, err := os.ReadFile(indexPath)
	if err != nil {
		return nil, fmt.Errorf("read index.json: %w", err)
	}

	var index struct {
		Manifests []struct {
			Digest    string `json:"digest"`
			MediaType string `json:"mediaType"`
			Annotations map[string]string `json:"annotations"`
		} `json:"manifests"`
	}
	if err := json.Unmarshal(indexData, &index); err != nil {
		return nil, fmt.Errorf("parse index.json: %w", err)
	}

	if len(index.Manifests) == 0 {
		return nil, fmt.Errorf("no manifests in index.json")
	}

	// Find manifest matching the tag, or use the first one.
	manifestDigest := index.Manifests[0].Digest
	for _, m := range index.Manifests {
		if m.Annotations["org.opencontainers.image.ref.name"] == tag {
			manifestDigest = m.Digest
			break
		}
	}

	// Read the manifest to find the config digest.
	manifestPath := filepath.Join(ociDir, "blobs", digestToPath(manifestDigest))
	manifestData, err := os.ReadFile(manifestPath)
	if err != nil {
		return nil, fmt.Errorf("read manifest: %w", err)
	}

	var manifest struct {
		Config struct {
			Digest string `json:"digest"`
		} `json:"config"`
	}
	if err := json.Unmarshal(manifestData, &manifest); err != nil {
		return nil, fmt.Errorf("parse manifest: %w", err)
	}

	// Read the image config.
	configPath := filepath.Join(ociDir, "blobs", digestToPath(manifest.Config.Digest))
	configData, err := os.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("read config: %w", err)
	}

	var imgCfg struct {
		Config struct {
			Entrypoint   []string          `json:"Entrypoint"`
			Cmd          []string          `json:"Cmd"`
			Env          []string          `json:"Env"`
			WorkingDir   string            `json:"WorkingDir"`
			ExposedPorts map[string]struct{} `json:"ExposedPorts"`
		} `json:"config"`
	}
	if err := json.Unmarshal(configData, &imgCfg); err != nil {
		return nil, fmt.Errorf("parse config: %w", err)
	}

	var ports []string
	for p := range imgCfg.Config.ExposedPorts {
		ports = append(ports, p)
	}

	return &ImageConfig{
		Entrypoint: imgCfg.Config.Entrypoint,
		Cmd:        imgCfg.Config.Cmd,
		Env:        imgCfg.Config.Env,
		WorkingDir: imgCfg.Config.WorkingDir,
		Ports:      ports,
	}, nil
}

// digestToPath converts "sha256:abc123..." to "sha256/abc123...".
func digestToPath(digest string) string {
	return strings.Replace(digest, ":", "/", 1)
}

// normalizeDockerRef adds docker.io/library/ prefix for bare image names.
// "nginx:latest" → "docker.io/library/nginx:latest"
// "ghcr.io/org/app:v1" → "ghcr.io/org/app:v1" (unchanged)
func normalizeDockerRef(ref string) string {
	// If ref contains no slashes, it's a Docker Hub library image.
	name, _, _ := strings.Cut(ref, ":")
	if !strings.Contains(name, "/") {
		return "docker.io/library/" + ref
	}
	// If the first component has no dots (e.g. "myorg/myapp"), it's Docker Hub.
	parts := strings.SplitN(name, "/", 2)
	if !strings.Contains(parts[0], ".") {
		return "docker.io/" + ref
	}
	return ref
}

// tagFromRef extracts the tag from an image reference, defaulting to "latest".
func tagFromRef(ref string) string {
	if _, tag, ok := strings.Cut(ref, ":"); ok {
		return tag
	}
	return "latest"
}

// SafeDirName converts an image ref to a safe directory name.
func SafeDirName(ref string) string {
	r := strings.NewReplacer("/", "_", ":", "_", ".", "_")
	return r.Replace(ref)
}
