# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    lsb-release \
    wget \
    gnupg2 \
    dbus-x11 \
    firefox \
    flatpak \
    sudo \
    "

ARG DE_PACKAGES=" \
    xfce4 \
    xfce4-settings \
    xubuntu-default-settings \
    xubuntu-icon-theme \
    papirus-icon-theme arc-theme \
    at-spi2-core \
    "

ARG ADDITIONAL_PACKAGES=" \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-whiskermenu-plugin \
    xfce4-docklike-plugin \
    xarchiver \
    mousepad \
    zip unzip p7zip-full \
    gnome-software gnome-software-plugin-flatpak \
    "
# 
# Prevent firefox snap
COPY scripts/ff-unsnap /etc/apt/preferences.d/ff-unsnap

RUN \
    # \
    # Setup Firefox PPA \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    apt-get update && \
    # \
    # Install core packages \
    apt-get install -y $CORE_PACKAGES && \
    # \
    # Install de \
    apt-get install -y $DE_PACKAGES && \
    # \
    # Install additional apps \
    apt-get install -y --no-install-recommends $ADDITIONAL_PACKAGES && \
    # \
    # Fixes \
    rm -f \
    /etc/xdg/autostart/xscreensaver.desktop && \
    # \
    # Clean \
    apt update && \
    apt-get remove -y foot && \
    apt autoremove -y &&\
    apt clean && \
    rm -rf \
        /config/.cache \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# 
# Replace launch scripts
COPY --chmod=777 scripts/launch-comp.sh scripts/startup.sh /opt/gow/
COPY --chmod=777 scripts/startdbus.sh /opt/gow/startdbus

#
# Include default xfce config
COPY --chmod=777 --chown=retro:retro scripts/xfce4 /opt/gow/xfce4

# 
# Fix locals
COPY scripts/locale /etc/default/locale

# 
# Allow anyone to start dbus without password
RUN echo "\nALL ALL=NOPASSWD: /opt/gow/startdbus" >> /etc/sudoers

# 
# Fix bwarp perms for flatpaks
RUN chmod u+s /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
