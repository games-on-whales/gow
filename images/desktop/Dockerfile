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
    xubuntu-default-settings \
    xubuntu-icon-theme \
    papirus-icon-theme arc-theme \
    "

ARG ADDITIONAL_PACKAGES=" \
    vlc \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-whiskermenu-plugin \
    xarchiver \
    mousepad \
    libreoffice libreoffice-writer \
    zip unzip p7zip-full \
    gnome-software gnome-software-plugin-flatpak \
    git \
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
    apt-get install -y --no-install-recommends $CORE_PACKAGES && \
    # \
    # Install de \
    apt-get install -y --no-install-recommends $DE_PACKAGES && \
    # \
    # Download and Install docklike plugin from mx repos \
    wget https://mxrepo.com/mx/repo/pool/main/x/xfce4-docklike-plugin/xfce4-docklike-plugin_0.4.1-0.1~mx23+1_amd64.deb && \
    dpkg -i xfce4-docklike-plugin_0.4.1-0.1~mx23+1_amd64.deb && \
    rm xfce4-docklike-plugin_0.4.1-0.1~mx23+1_amd64.deb && \
    # \
    # Install additional apps \
    apt reinstall -y xfce4-settings && \
    apt-get install -y $ADDITIONAL_PACKAGES

RUN \
    # \
    # Fixes \
    rm -f \
    /etc/xdg/autostart/xscreensaver.desktop

RUN \
    # \
    # Clean \
    apt update && \
    apt-get remove -y \
	foot && \
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
