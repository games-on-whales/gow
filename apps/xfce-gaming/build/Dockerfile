ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/xfce:edge

FROM ${BASE_APP_IMAGE}

ARG STEAM_PACKAGES=" \
    steam \
    dbus-daemon \
    dbus-system-bus-common \
    dbus-session-bus-common \
    whoopsie \
    network-manager \
    bluez \
    ibus \
    pkexec \
    file \
    xdg-user-dirs \
    xdg-utils \
    pciutils \
    lsb-release \
    mesa-utils \
    libfontconfig1:i386 \
    libfontconfig1:amd64 \
    libfreetype6 \
"

ARG HEROIC_PACKAGES=" \
    libnotify4 \
    libsecret-1-0 \
    cabextract \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-plugins-base:i386 gstreamer1.0-plugins-good:i386 gstreamer1.0-plugins-bad:i386 gstreamer1.0-plugins-ugly:i386 gstreamer1.0-libav:i386 \
" 

ARG CORE_PACKAGES=" \
    curl \
    software-properties-common \
    libfreetype6:i386 \
    libasound2-plugins:i386 \
    libsdl2-2.0-0:i386 \
    libdbus-1-3:i386 \
    libsqlite3-0:i386 \
    libvulkan1 \
    libvulkan1:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    wine64 \
    wine32 \
    wine-stable \
    winetricks \
    unzip \
    p7zip-full \
    xz-utils \
    tar \
    wget \
    ca-certificates \
    zenity \
"

ARG STEAM_AVOID_PACKAGES=" \
    nvidia-driver-libs- nvidia-vulkan-icd- \
"

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y $CORE_PACKAGES

WORKDIR /

RUN <<_INSTALL_STEAM
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

add-apt-repository multiverse && \
apt-get update -y && \
apt-get install -y $STEAM_PACKAGES $STEAM_AVOID_PACKAGES && \
# Fix steam updater UI font file
ln -s /usr/share/fonts/truetype/dejavu /usr/share/fonts/truetype/ttf-dejavu && \
# fix NetworkManager not picking up devices
touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf \
# skip annoying debian dialog
rm /usr/bin/zenity && ln -s /usr/bin/true /usr/bin/zenity \
# refresh system font cache. For font warnings on startup see: https://github.com/ValveSoftware/steam-runtime/issues/482
fc-cache -f -v \
# create symlink for improved decky loader compatibility
ln -sf "$HOME" /home/deck \
_INSTALL_STEAM

RUN <<_INSTALL_HEROIC
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh
apt-get install -y $HEROIC_PACKAGES
github_download "Heroic-Games-Launcher/HeroicGamesLauncher" ".assets[]|select(.name|endswith(\"amd64.deb\")).browser_download_url" "heroic.deb"
dpkg -i heroic.deb
rm heroic.deb
_INSTALL_HEROIC

RUN <<_CLEANUP
apt-get remove -y python3-six software-properties-common && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/*
_CLEANUP

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE