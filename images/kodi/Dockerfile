# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    dbus \
    flatpak \
    "

RUN <<_INSTALL_FLATPAK

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

_INSTALL_FLATPAK

#
# System wide install of Kodi
RUN <<_INSTALL_KODI

set -e
# Fix bwarp perms for flatpaks
chmod u+s /usr/bin/bwrap
service dbus start
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive --system tv.kodi.Kodi
flatpak override --system tv.kodi.Kodi --filesystem=home

_INSTALL_KODI

# 
# Replace launch scripts
COPY overlay /
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/Xbox_controller.xml /opt/gow/Xbox_controller.xml
COPY configs/Switch_controller.xml /opt/gow/Switch_controller.xml
COPY configs/PS_controller.xml /opt/gow/PS_controller.xml
COPY configs/settings.xml /opt/gow/settings.xml

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE