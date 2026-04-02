# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN dnf install -y \
    # Core \
    wget \
    dbus-x11 \
    flatpak \
    sudo \
    # Desktop environment \
    @xfce-desktop-environment \
    xfce4-settings \
    papirus-icon-theme arc-theme \
    at-spi2-core \
    # Additional apps \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-whiskermenu-plugin \
    xfce4-docklike-plugin \
    xarchiver \
    mousepad \
    zip unzip p7zip \
    gnome-software gnome-software-plugin-flatpak \
    # Browser \
    firefox \
    && dnf remove -y foot 2>/dev/null || true \
    && dnf clean all

# Remove xscreensaver autostart if present
RUN rm -f /etc/xdg/autostart/xscreensaver.desktop

# Replace launch scripts
COPY --chmod=777 scripts/launch-comp.sh scripts/startup.sh /opt/gow/
COPY --chmod=777 scripts/startdbus.sh /opt/gow/startdbus

# Include default xfce config
COPY --chmod=777 --chown=retro:retro scripts/xfce4 /opt/gow/xfce4

# Fix locales
COPY scripts/locale /etc/default/locale

# Allow anyone to start dbus without password
RUN echo -e "\nALL ALL=NOPASSWD: /opt/gow/startdbus" >> /etc/sudoers

# Fix bwrap perms for flatpaks
RUN chmod u+s /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
