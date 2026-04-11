# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# Plex HTPC on Linux is only officially distributed via Flathub, but the
# underlying artifact is a plain tarball hosted at artifacts.plex.tv. We
# resolve the current version by parsing the upstream Flathub manifest at
# build time.
RUN <<_INSTALL_PLEX_HTPC
set -e

dnf install -y \
    curl bzip2 \
    alsa-lib libva libvdpau mesa-libEGL mesa-libGL \
    libxcb xcb-util-cursor xcb-util-image xcb-util-keysyms \
    xcb-util-renderutil xcb-util-wm libxkbcommon-x11 nss fontconfig dbus-libs

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

dnf clean all
_INSTALL_PLEX_HTPC

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
