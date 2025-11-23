# syntax=docker/dockerfile:1.4
ARG FIREFOX_IMAGE=ghcr.io/games-on-whales/firefox:edge

# hadolint ignore=DL3006
FROM ${FIREFOX_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    wget \
    gpg \
    libva-glx2 \
    libvdpau1 \
    libva-drm2 \
    libcurl4 \
    libva-wayland2 \
    xdg-utils \
"

# Install ShadowPC
RUN <<_INSTALL_PACKAGES
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES
wget -qO /tmp/shadowpc.deb https://update.shadow.tech/launcher/preprod/linux/x86_64/shadow-beta-amd64.deb
apt-get update
apt-get install -y --no-install-recommends /tmp/shadowpc.deb
rm /tmp/shadowpc.deb
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PACKAGES

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
