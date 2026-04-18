# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    wget \
    dbus \
    firefox \
    flatpak \
    whoopsie \
    locales \
    xwayland \
    "

ARG DE_PACKAGES=" \
    kde-plasma-desktop \
    qt6-wayland \
    qtwayland5 \
    pipewire \
    "

RUN <<_INSTALL_BASE
  set -e

  # Setup Firefox PPA
  apt-get update
  apt-get install -y --no-install-recommends software-properties-common gpg-agent
  add-apt-repository -y ppa:mozillateam/ppa
  apt-get update

  # Install core packages
  apt-get install -y $CORE_PACKAGES

  # Install de
  apt-get install -y $DE_PACKAGES

  # Install additional apps
  apt-get install -y --no-install-recommends $ADDITIONAL_PACKAGES

  # Clean
  apt autoremove -y
  apt clean
  rm -rf /config/.cache /var/lib/apt/lists/* /var/tmp/* /tmp/*

_INSTALL_BASE

COPY <<_APT_PIN /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
_APT_PIN

RUN <<_FIXES
  set -e

  chmod u+s /usr/bin/bwrap
  service dbus start
  flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  locale-gen en_US.UTF-8
_FIXES

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    QT_QPA_PLATFORM=wayland;wayland-egl \
    QT_QPA_PLATFORMTHEME=kde \
    GDK_BACKEND=wayland \
    CLUTTER_BACKEND=wayland \
    SDL_VIDEODRIVER=wayland


# Replace launch scripts
COPY overlay /
COPY --chmod=777 scripts/startup.sh /opt/gow/

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
