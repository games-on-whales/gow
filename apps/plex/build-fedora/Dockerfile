# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# Plex HTPC on Linux is only officially distributed via Flathub — Plex does
# not publish any .deb/.rpm/AppImage, and the raw tarball at artifacts.plex.tv
# is behind Cloudflare bot-management that blocks standard HTTP clients. The
# only reliable install path is therefore `flatpak install` at build time.
RUN <<_INSTALL_PLEX_HTPC
set -e

dnf install -y flatpak xdg-desktop-portal

# bwrap needs to be setuid inside the container runtime.
chmod u+s /usr/bin/bwrap

flatpak remote-add --system --if-not-exists \
    flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --system -y --noninteractive flathub tv.plex.PlexHTPC

dnf clean all
_INSTALL_PLEX_HTPC

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
