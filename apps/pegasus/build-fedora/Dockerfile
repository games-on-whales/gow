ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

RUN dnf install -y \
    gstreamer1-plugins-base \
    fuse-zip \
    openssl-libs \
    && dnf clean all

# Setup ISO mounting location
RUN mkdir -p /media/iso_mount && chown 1000:1000 /media/iso_mount

# Install pegasus via AppImage (no .deb available for Fedora)
RUN <<_INSTALL_PEGASUS
#!/bin/bash
set -e

echo "**** Installing pegasus ****"

# Download the Pegasus AppImage from GitHub releases
cd /tmp
curl -s https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous | \
jq -r '.assets[] | select(.name | contains("AppImage")) | .browser_download_url' | head -1 | \
xargs curl -fsSL -o /usr/local/bin/pegasus-fe

chmod +x /usr/local/bin/pegasus-fe

# Cleanup
rm -rf /tmp/*
_INSTALL_PEGASUS

# Copy config files
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/pegasus.sh /bin/pegasus.sh

# Copy Pegasus related files
COPY scripts/tools/*.sh /bin/
COPY configs /cfg

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
