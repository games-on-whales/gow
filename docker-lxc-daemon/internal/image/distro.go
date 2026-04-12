// Package image resolves Docker image references to LXC template arguments.
package image

import (
	"strings"
)

// distroMeta holds the LXC distro name and a version→codename map for a
// given distro family.
type distroMeta struct {
	lxcName    string
	versionMap map[string]string // Docker tag → LXC release name
}

// knownDistros maps Docker image names (as they appear before the colon) to
// their LXC download-template equivalents.
var knownDistros = map[string]distroMeta{
	"ubuntu": {
		lxcName: "ubuntu",
		versionMap: map[string]string{
			// version numbers
			"24.04": "noble",
			"22.04": "jammy",
			"20.04": "focal",
			"18.04": "bionic",
			"16.04": "xenial",
			// codenames (pass-through)
			"noble":  "noble",
			"jammy":  "jammy",
			"focal":  "focal",
			"bionic": "bionic",
			"xenial": "xenial",
			// aliases
			"latest":  "jammy",
			"lts":     "jammy",
			"rolling": "noble",
			"devel":   "noble",
		},
	},
	"debian": {
		lxcName: "debian",
		versionMap: map[string]string{
			"12":       "bookworm",
			"11":       "bullseye",
			"10":       "buster",
			"9":        "stretch",
			"bookworm": "bookworm",
			"bullseye": "bullseye",
			"buster":   "buster",
			"stretch":  "stretch",
			"stable":   "bookworm",
			"oldstable": "bullseye",
			"latest":   "bookworm",
			// slim/slim-variant → same base
			"slim":           "bookworm",
			"bookworm-slim":  "bookworm",
			"bullseye-slim":  "bullseye",
		},
	},
	"alpine": {
		lxcName: "alpine",
		versionMap: map[string]string{
			"latest": "3.19",
			"edge":   "edge",
			// semver tags handled separately in normalizeRelease
		},
	},
	"fedora": {
		lxcName: "fedora",
		versionMap: map[string]string{
			"latest": "39",
			"39":     "39",
			"38":     "38",
			"40":     "40",
		},
	},
	"centos": {
		lxcName: "centos",
		versionMap: map[string]string{
			"stream9": "9-Stream",
			"stream8": "8-Stream",
			"latest":  "9-Stream",
			"9":       "9-Stream",
			"8":       "8-Stream",
		},
	},
	"rockylinux": {
		lxcName: "rockylinux",
		versionMap: map[string]string{
			"9":      "9",
			"8":      "8",
			"latest": "9",
		},
	},
	"almalinux": {
		lxcName: "almalinux",
		versionMap: map[string]string{
			"9":      "9",
			"8":      "8",
			"latest": "9",
		},
	},
	"archlinux": {
		lxcName: "archlinux",
		versionMap: map[string]string{
			"latest": "current",
			"base":   "current",
		},
	},
	"opensuse": {
		lxcName: "opensuse",
		versionMap: map[string]string{
			"leap":      "15.5",
			"tumbleweed": "tumbleweed",
			"latest":    "15.5",
		},
	},
	"kali": {
		lxcName: "kali",
		versionMap: map[string]string{
			"latest":  "current",
			"rolling": "current",
		},
	},
}

// resolveDistro returns the LXC distro name and release for a known distro
// image name and tag. Returns "", "" if the name is not a known distro.
func resolveDistro(name, tag string) (distro, release string) {
	meta, ok := knownDistros[strings.ToLower(name)]
	if !ok {
		return "", ""
	}

	tag = stripDockerVariantSuffix(tag)

	if r, ok := meta.versionMap[tag]; ok {
		return meta.lxcName, r
	}

	// Alpine semver pass-through: "3.18" → "3.18", "3.19.1" → "3.19"
	if meta.lxcName == "alpine" && looksLikeSemver(tag) {
		return meta.lxcName, majorMinor(tag)
	}

	return "", ""
}

// isKnownDistro reports whether name is a recognised distro image.
func isKnownDistro(name string) bool {
	_, ok := knownDistros[strings.ToLower(name)]
	return ok
}

// stripDockerVariantSuffix removes suffixes that Docker uses but LXC doesn't
// understand: -slim, -bullseye, -alpine, date stamps like -20240101, etc.
func stripDockerVariantSuffix(tag string) string {
	suffixes := []string{
		"-slim", "-alpine", "-bullseye", "-bookworm", "-buster",
		"-jammy", "-focal", "-bionic",
	}
	for _, s := range suffixes {
		if strings.HasSuffix(tag, s) {
			tag = tag[:len(tag)-len(s)]
		}
	}
	// Strip trailing date stamp: "22.04-20240101" → "22.04"
	if idx := strings.LastIndex(tag, "-"); idx != -1 {
		suffix := tag[idx+1:]
		if len(suffix) == 8 && isAllDigits(suffix) {
			tag = tag[:idx]
		}
	}
	return tag
}

func looksLikeSemver(s string) bool {
	parts := strings.Split(s, ".")
	if len(parts) < 2 {
		return false
	}
	for _, p := range parts {
		if !isAllDigits(p) {
			return false
		}
	}
	return true
}

func majorMinor(s string) string {
	parts := strings.Split(s, ".")
	if len(parts) >= 2 {
		return parts[0] + "." + parts[1]
	}
	return s
}

func isAllDigits(s string) bool {
	for _, c := range s {
		if c < '0' || c > '9' {
			return false
		}
	}
	return len(s) > 0
}
