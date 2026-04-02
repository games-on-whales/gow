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

# Install pegasus via static x11 build (no .deb or AppImage available for Fedora)
RUN <<_INSTALL_PEGASUS
#!/bin/bash
set -e

echo "**** Installing pegasus ****"

cd /tmp
curl -s https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous | \
jq -r '.assets[] | select(.name | contains("x11-static.zip")) | .browser_download_url' | head -1 | \
xargs curl -fsSL -o pegasus.zip

dnf install -y unzip
unzip pegasus.zip -d /tmp/pegasus
cp /tmp/pegasus/pegasus-fe /usr/local/bin/pegasus-fe
chmod +x /usr/local/bin/pegasus-fe
dnf remove -y unzip

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
