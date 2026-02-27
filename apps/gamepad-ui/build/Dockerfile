ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

ARG LUTRIS_PACKAGES=" \
     cabextract \
     curl \
     fluid-soundfont-gs \
     gir1.2-gtk-3.0 \
     gir1.2-notify-0.7 \
     gir1.2-webkit2-4.1 \
     libgdk-pixbuf2* \
     librsvg2* \
     libasound2-plugins:i386 \
     libdbus-1-3:i386 \
     libfreetype6:i386 \
     libgl1:i386 \
     libsdl2-2.0-0:i386 \
     libsqlite3-0:i386 \
     libvulkan1 \
     libvulkan1:i386 \
     mesa-utils \
     mesa-vulkan-drivers \
     mesa-vulkan-drivers:i386 \
     p7zip \
     python3-dbus \
     python3-distro \
     python3-gi-cairo \
     python3-lxml \
     python3-magic \
     python3-pil \
     python3-requests \
     python3-setproctitle \
     python3-yaml \
     unzip \
     vulkan-tools \
     wine-stable \
     wine32 \
     wine64 \
     winetricks \
     x11-xserver-utils \
     zenity \
     libfuse2 \
     libfuse2t64 \
     libgstreamer-gl1.0-0 \
     fuseiso \
     fuse-zip \
    "


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $LUTRIS_PACKAGES && \
# Cleanup \
    apt-get autoremove -y

RUN <<_INSTALL_LUTRIS
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "lutris/lutris" ".assets[]|select(.name|endswith(\".deb\")).browser_download_url" "lutris.deb"
dpkg -i lutris.deb
rm lutris.deb
_INSTALL_LUTRIS

# Install Lutris Gamepad UI
ENV APPIMAGE_URL="https://github.com/andrew-ld/lutris-gamepad-ui/releases/latest/download/lutris-gamepad-ui-x64.AppImage"
ENV APPIMAGE_NAME="lutris-gamepad-ui.AppImage"
ENV APP_DIR="/opt/gow/app"

# Download and extract AppImage
RUN curl -L ${APPIMAGE_URL} -o /tmp/app.AppImage && \
    chmod +x /tmp/app.AppImage && \
    /tmp/app.AppImage --appimage-extract && \
    mv squashfs-root ${APP_DIR} && \
    rm -rf /tmp/app.AppImage && \
    chown -R 1000:1000 ${APP_DIR}


RUN mkdir -pm 777 /var/lutris/ && \
    mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY --chmod=777 scripts/gamepadui.sh /bin/gamepadui.sh
COPY configs/lutris-system.yml /opt/gow/lutris-system.yml
COPY configs/lutris-lutris.conf /opt/gow/lutris-lutris.conf
COPY configs/gamepadui.json /opt/gow/gamepadui.json

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
