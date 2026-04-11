# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Plex HTPC on Linux is only officially distributed via Flathub, but the
# underlying artifact is a plain tarball hosted at artifacts.plex.tv. We
# resolve the current version by parsing the upstream Flathub manifest at
# build time, so new upstream releases are picked up automatically when the
# Flathub bot bumps the manifest.
RUN <<_INSTALL_PLEX_HTPC
set -e
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates curl bzip2 \
    libasound2t64 libva2 libva-drm2 libva-x11-2 libvdpau1 libegl1 libgl1 \
    libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 \
    libxcb-xkb1 libxkbcommon-x11-0 libnss3 libfontconfig1 libdbus-1-3

TARBALL_URL=$(curl -fsSL \
    https://raw.githubusercontent.com/flathub/tv.plex.PlexHTPC/master/tv.plex.PlexHTPC.yml \
    | grep -oE 'https://artifacts\.plex\.tv/plex-htpc-stable/[^ ]+-linux-x86_64\.tar\.bz2' \
    | head -n1)

if [ -z "$TARBALL_URL" ]; then
    echo "Failed to resolve Plex HTPC tarball URL from Flathub manifest" >&2
    exit 1
fi

echo "Downloading Plex HTPC from $TARBALL_URL"
mkdir -p /opt/plex-htpc
curl -fsSL "$TARBALL_URL" -o /tmp/plex-htpc.tar.bz2
tar -xjf /tmp/plex-htpc.tar.bz2 -C /opt/plex-htpc
rm -f /tmp/plex-htpc.tar.bz2

# Tarball may extract into a single top-level directory — flatten it.
if [ ! -f /opt/plex-htpc/Plex.sh ]; then
    INNER=$(find /opt/plex-htpc -mindepth 1 -maxdepth 1 -type d | head -n1)
    if [ -n "$INNER" ] && [ -f "$INNER/Plex.sh" ]; then
        mv "$INNER"/* /opt/plex-htpc/
        rmdir "$INNER"
    fi
fi

if [ ! -x /opt/plex-htpc/Plex.sh ]; then
    echo "Plex.sh launcher missing from tarball layout" >&2
    ls -la /opt/plex-htpc >&2
    exit 1
fi

ln -sf /opt/plex-htpc/Plex.sh /usr/local/bin/plex-htpc

apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PLEX_HTPC

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
