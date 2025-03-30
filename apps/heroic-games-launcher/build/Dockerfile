# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

#Added 32-bit libs because of GE-Proton needs
ARG REQUIRED_PACKAGES=" \
    libfreetype6:i386 \
    libvulkan1 \
    libvulkan1:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    wine64 \
    wine32 \
    libasound2-plugins:i386 \
    libsdl2-2.0-0:i386 \
    libdbus-1-3:i386 \
    libsqlite3-0:i386 \
    wine-stable \
    winetricks \
    zenity \
    libnotify4 \
    xdg-utils \
    libsecret-1-0 \
    curl \
    unzip \
    p7zip-full \
    cabextract \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-plugins-base:i386 gstreamer1.0-plugins-good:i386 gstreamer1.0-plugins-bad:i386 gstreamer1.0-plugins-ugly:i386 gstreamer1.0-libav:i386 \
    tar \
    wget \
    ca-certificates \
    xz-utils"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN <<_INSTALL_HEROIC
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "Heroic-Games-Launcher/HeroicGamesLauncher" ".assets[]|select(.name|endswith(\"amd64.deb\")).browser_download_url" "heroic.deb"
dpkg -i heroic.deb
rm heroic.deb
_INSTALL_HEROIC

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
