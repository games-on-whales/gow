# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

######################################
FROM lizardbyte/sunshine:v0.18.1-ubuntu-22.04 AS sunshine-image

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE} AS sunshine

ARG TARGETARCH TARGETVARIANT

ARG REQUIRED_PACKAGES="\
    libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri \
    libvulkan1 \
    libvdpau1 libnuma1 \
    libva-drm2 libva-x11-2 va-driver-all \
    libavahi-client3 \
    libcap2-bin \
    "

ARG REQUIRED_PACKAGES_amd64="\
    i965-va-driver-shaders \
    intel-media-va-driver-non-free \
    libdrm-intel1 \
"

ARG REQUIRED_PACKAGES_arm64="\
"

# Install using the official .deb package
# This will take care of installing the required dependencies
# hadolint ignore=SC2086
RUN \
  --mount=type=bind,from=sunshine-image,source=/sunshine.deb,target=/sunshine.deb \
  <<_INSTALL_PACKAGES
#!/bin/bash
set -e
export REQUIRED_PACKAGES_ARCH="REQUIRED_PACKAGES_${TARGETARCH}${TARGETVARIANT}"
apt-get update -y
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES ${!REQUIRED_PACKAGES_ARCH}
apt-get install -y --no-install-recommends -f /sunshine.deb
rm -rf /var/lib/apt/lists/*
_INSTALL_PACKAGES

# Utils for debugging
# RUN apt-get update -y && \
#     apt-get install -y --no-install-recommends gdb vainfo ffmpeg \
#     && apt-get remove -y software-properties-common \
#     && rm -rf /var/lib/apt/lists/*

# Config files
COPY configs/sunshine.conf /cfg/sunshine.conf
COPY configs/apps.json /cfg/apps.json

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp 48010 48010/udp 47998-48000/udp

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
