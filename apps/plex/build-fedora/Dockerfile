# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_PLEX
set -e

dnf install -y \
    nss \
    libXScrnSaver \
    alsa-lib \
    mesa-libgbm \
    gtk3 \
    libsecret \
    libva \
    libvdpau \
    curl \
    jq

URL=$(curl -fsSL "https://plex.tv/api/downloads/plex-htpc.json" \
    | jq -r '[.. | objects | select(.url? != null) | .url] | map(select(endswith("x86_64.rpm"))) | .[0]')

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve Plex HTPC .rpm download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/plex-htpc.rpm "$URL"
dnf install -y /tmp/plex-htpc.rpm
rm -f /tmp/plex-htpc.rpm

dnf clean all
_INSTALL_PLEX

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
