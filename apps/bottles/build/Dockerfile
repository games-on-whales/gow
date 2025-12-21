# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    dbus \
    flatpak \
    python3 \
    "

RUN <<_INSTALL_BOTTLES

set -e
apt-get update
# Install core packages
apt-get install -y --no-install-recommends $CORE_PACKAGES
# Clean
apt-get update
apt-get remove -y foot
apt-get autoremove -y
apt-get clean
rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Allow anyone to start dbus without password
echo "\nALL ALL=NOPASSWD: /opt/gow/startdbus" >> /etc/sudoers

# Fix bwarp perms for flatpaks
chmod u+s /usr/bin/bwrap
service dbus start
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive --system com.usebottles.bottles
flatpak override --system com.usebottles.bottles --filesystem=home

_INSTALL_BOTTLES

# 
# Replace launch scripts
COPY overlay /
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE