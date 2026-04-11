# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libnss3 \
    libxss1 \
    libasound2t64 \
    libgbm1 \
    libgtk-3-0 \
    libsecret-1-0 \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    libvdpau1 \
    "

RUN <<_INSTALL_PLEX
set -e
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES ca-certificates curl jq

URL=$(curl -fsSL "https://plex.tv/api/downloads/plex-htpc.json" \
    | jq -r '[.. | objects | select(.url? != null) | .url] | map(select(endswith("amd64.deb"))) | .[0]')

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve Plex HTPC .deb download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/plex-htpc.deb "$URL"
apt-get install -y /tmp/plex-htpc.deb
rm -f /tmp/plex-htpc.deb

apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PLEX

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
