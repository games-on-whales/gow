# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# Install RPM Fusion for wine and multimedia codecs
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Wine, 32-bit libs, and multimedia packages
RUN dnf install -y \
    freetype.i686 \
    vulkan-loader vulkan-loader.i686 \
    mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
    wine wine.i686 \
    winetricks \
    alsa-plugins-pulseaudio.i686 \
    sdl2-compat.i686 \
    dbus-libs.i686 \
    sqlite-libs.i686 \
    zenity \
    libnotify \
    xdg-utils \
    libsecret \
    curl \
    unzip \
    p7zip \
    cabextract \
    gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly-free \
    gstreamer1-plugins-base.i686 gstreamer1-plugins-good.i686 gstreamer1-plugins-bad-free.i686 gstreamer1-plugins-ugly-free.i686 \
    tar \
    wget \
    ca-certificates \
    xz \
    && dnf clean all

WORKDIR /

# Install Heroic Games Launcher from RPM
RUN <<_INSTALL_HEROIC
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "Heroic-Games-Launcher/HeroicGamesLauncher" ".assets[]|select(.name|endswith(\".rpm\"))|select(.name|contains(\"x86_64\")).browser_download_url" "heroic.rpm"
dnf install -y ./heroic.rpm
rm heroic.rpm
_INSTALL_HEROIC

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
