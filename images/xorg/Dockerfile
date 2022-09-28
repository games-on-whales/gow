ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV \
    DISPLAY=:0 \
    XORG_VERBOSE=3

ARG DEBIAN_FRONTEND=noninteractive

# X11 taken from https://github.com/Kry07/docker-xorg/blob/xonly/Dockerfile\
# Video driver taken from https://github.com/mviereck/x11docker/wiki/Hardware-acceleration#hardware-acceleration-with-open-source-drivers-mesa \
# wget is needed by ensure-nvidia-xorg-driver
ARG REQUIRED_PACKAGES=" \
    wget \
    xserver-xorg-core xfonts-base x11-apps \
    x11-session-utils x11-utils x11-xfs-utils \
    x11-xserver-utils xauth x11-common \
    xz-utils unzip avahi-utils dbus \
    mesa-utils mesa-utils-extra \
    vulkan-tools \
    libgl1-mesa-glx libgl1-mesa-dri libglu1-mesa \
    xserver-xorg-video-all \
    xserver-xorg-input-libinput \
    jwm libxft2 libxext6 breeze-cursor-theme \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

COPY configs/xorg.conf /usr/share/X11/xorg.conf.d/20-sunshine.conf
COPY configs/xorg-nvidia.conf /usr/share/X11/xorg.conf.d/09-nvidia-custom-location.conf
COPY configs/desktop.jwmrc.xml $HOME/.jwmrc

# TODO: is this really needed anymore? run-gow automatically mounts these from
# the host most of the time. I suppose it's helpful for less-well-supported distros
COPY --chmod=777 scripts/ensure-nvidia-xorg-driver.sh /opt/gow/ensure-nvidia-xorg-driver.sh

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
