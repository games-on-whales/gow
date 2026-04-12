package image

import (
	"fmt"
	"strings"
)

// ResolvedImage is the result of resolving a Docker image reference.
type ResolvedImage struct {
	// Ref is the canonical input reference, e.g. "ubuntu:22.04".
	Ref string
	// Kind is either KindDistro or KindApp.
	Kind Kind
	// Distro is the LXC download-template distro name (e.g. "ubuntu").
	// For KindApp this is the base distro.
	Distro string
	// Release is the LXC download-template release (e.g. "jammy").
	Release string
	// Arch is the target architecture (e.g. "amd64").
	Arch string
	// App is populated only for KindApp; it describes the packages to install.
	App *AppDef
	// BaseRef is populated only for KindApp; it is the base image reference
	// that must be resolved and pulled before this image can be built.
	BaseRef string
	// TemplateContainerName is the LXC container name used as the clone
	// source for this image, e.g. "__template_ubuntu_22.04".
	TemplateContainerName string
}

// Kind classifies a resolved image.
type Kind int

const (
	KindDistro Kind = iota // pure OS image — resolved directly from LXC download template
	KindApp                // application image — base distro + package install
)

// Resolve parses a Docker image reference and returns a ResolvedImage.
// arch should be "amd64" or "arm64".
func Resolve(ref, arch string) (*ResolvedImage, error) {
	if arch == "" {
		arch = "amd64"
	}

	name, tag := parseRef(ref)

	// 1. Try distro image.
	if isKnownDistro(name) {
		distro, release := resolveDistro(name, tag)
		if distro == "" {
			return nil, fmt.Errorf("image: unknown release %q for distro %q", tag, name)
		}
		return &ResolvedImage{
			Ref:                   ref,
			Kind:                  KindDistro,
			Distro:                distro,
			Release:               release,
			Arch:                  arch,
			TemplateContainerName: templateName(distro, release),
		}, nil
	}

	// 2. Try known app image.
	if def, ok := lookupApp(name); ok {
		baseName, baseTag := parseRef(def.Base)
		baseDistro, baseRelease := resolveDistro(baseName, baseTag)
		if baseDistro == "" {
			return nil, fmt.Errorf("image: app %q has unknown base %q", name, def.Base)
		}
		appDef := def // copy
		return &ResolvedImage{
			Ref:                   ref,
			Kind:                  KindApp,
			Distro:                baseDistro,
			Release:               baseRelease,
			Arch:                  arch,
			App:                   &appDef,
			BaseRef:               def.Base,
			TemplateContainerName: appTemplateName(name, tag),
		}, nil
	}

	return nil, fmt.Errorf("image: %q is not a known distro or app image; "+
		"add it to the app registry or use a supported distro image", ref)
}

// parseRef splits "name:tag", "name" (defaults tag to "latest"),
// and "registry/name:tag" (strips registry prefix for lookup purposes).
func parseRef(ref string) (name, tag string) {
	// Strip registry prefix (anything with a dot or colon before the first slash)
	parts := strings.SplitN(ref, "/", 2)
	bare := ref
	if len(parts) == 2 {
		prefix := parts[0]
		if strings.Contains(prefix, ".") || strings.Contains(prefix, ":") {
			bare = parts[1]
		}
	}

	if idx := strings.LastIndex(bare, ":"); idx != -1 {
		name = bare[:idx]
		tag = bare[idx+1:]
	} else {
		name = bare
		tag = "latest"
	}
	// Strip any remaining path component for lookup (e.g. "library/ubuntu" → "ubuntu")
	if idx := strings.LastIndex(name, "/"); idx != -1 {
		name = name[idx+1:]
	}
	return
}

// templateName returns the LXC container name used as the clone source for a
// distro image, e.g. "__template_ubuntu_jammy".
func templateName(distro, release string) string {
	return fmt.Sprintf("__template_%s_%s", distro, sanitize(release))
}

// appTemplateName returns the LXC container name for an app image template.
func appTemplateName(app, tag string) string {
	return fmt.Sprintf("__template_app_%s_%s", sanitize(app), sanitize(tag))
}

// sanitize replaces characters that are not safe in an LXC container name.
func sanitize(s string) string {
	return strings.NewReplacer(
		":", "_",
		"/", "_",
		" ", "_",
		".", "_",
	).Replace(s)
}
