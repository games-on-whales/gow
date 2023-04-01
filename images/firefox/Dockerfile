# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libpci3 \
    libegl1 \
    libvulkan1 \
    mesa-vulkan-drivers \
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

ARG NV_VERSION
RUN if [ -n "$NV_VERSION" ]; then \
    apt-get update -y && \
    apt-get install -y --no-install-recommends curl kmod pkg-config libglvnd-dev mesa-utils vulkan-tools && \
    curl -LO https://download.nvidia.com/XFree86/Linux-x86_64/$NV_VERSION/NVIDIA-Linux-x86_64-$NV_VERSION.run && \
    chmod +x NVIDIA-Linux-x86_64-$NV_VERSION.run && \
    ./NVIDIA-Linux-x86_64-$NV_VERSION.run --silent -z --skip-depmod --skip-module-unload --no-nvidia-modprobe --no-kernel-modules --no-kernel-module-source && \
    rm ./NVIDIA-Linux-x86_64-$NV_VERSION.run \
    ; fi

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
