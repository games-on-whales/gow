# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_KODI

set -e

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf install -y \
    dbus \
    python3 \
    kodi

# Remove foot terminal if present
dnf remove -y foot 2>/dev/null || true
dnf clean all

# Fix bwrap perms for flatpaks
chmod u+s /usr/bin/bwrap

_INSTALL_KODI

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
