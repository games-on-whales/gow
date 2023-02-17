# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libpci3 \
    libegl1 \
    firefox \
"

COPY <<_APT_PIN /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
_APT_PIN

RUN <<_INSTALL_PACKAGES
apt-get update
apt-get install -y --no-install-recommends software-properties-common gpg-agent
add-apt-repository ppa:mozillateam/ppa
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES
apt-get remove -y software-properties-common gpg-agent
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PACKAGES

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
