FROM ubuntu:21.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"
ENV DISPLAY :0
ENV XORG_VERBOSE 3

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo software-properties-common wget kmod \
    # Video driver taken from https://github.com/mviereck/x11docker/wiki/Hardware-acceleration#hardware-acceleration-with-open-source-drivers-mesa \
    mesa-utils mesa-utils-extra \
    # X11 taken from https://github.com/Kry07/docker-xorg/blob/xonly/Dockerfile\
    xz-utils unzip avahi-utils dbus \
	xserver-xorg-core libgl1-mesa-glx libgl1-mesa-dri libglu1-mesa xfonts-base \
	x11-session-utils x11-utils x11-xfs-utils x11-xserver-utils xauth x11-common \
    # Video drivers
    xserver-xorg-video-all \
    # Input drivers \
    xserver-xorg-input-libinput \
    # Window manager \
    jwm libxft2 libxext6 breeze-cursor-theme \
    && rm -rf /var/lib/apt/lists/*

COPY xorg/configs/xorg.conf /usr/share/X11/xorg.conf.d/20-sunshine.conf
COPY xorg/configs/xorg-nvidia.conf /usr/share/X11/xorg.conf.d/09-nvidia-custom-location.conf
COPY xorg/configs/desktop.jwmrc.xml /root/.jwmrc

COPY xorg/scripts/ensure-nvidia-xorg-driver.sh /ensure-nvidia-xorg-driver.sh
COPY xorg/scripts/startup.sh /startup.sh
# Common scripts
COPY --chmod=777 common/* /bin/

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
