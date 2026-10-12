# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    dbus \
    python3 \
    software-properties-common \
    "
ARG EXTRA_REPOS="universe"
ARG ADDITIONAL_PACKAGES="kodi"
RUN <<_INSTALL_KODI

set -e
apt-get update
# Install core packages
apt-get install -y --no-install-recommends $CORE_PACKAGES
# Clean
apt-get update
add-apt-repository -y $EXTRA_REPOS
apt-get update
apt install -y $ADDITIONAL_PACKAGES

apt-get remove -y foot
apt-get autoremove -y
apt-get clean
rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Fix bwarp perms for flatpaks
chmod u+s /usr/bin/bwrap
service dbus start


_INSTALL_KODI

# 
# Replace launch scripts
# Copy overlay files by path: `COPY overlay /` applies the source dir modes
# to / and /etc, which a restrictive builder umask makes unreadable.
COPY --chmod=755 overlay/etc/cont-init.d/99-startdbus.sh /etc/cont-init.d/99-startdbus.sh
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY --chmod=644 configs/Xbox_controller.xml /opt/gow/Xbox_controller.xml
COPY --chmod=644 configs/Switch_controller.xml /opt/gow/Switch_controller.xml
COPY --chmod=644 configs/PS_controller.xml /opt/gow/PS_controller.xml
COPY --chmod=644 configs/settings.xml /opt/gow/settings.xml

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE