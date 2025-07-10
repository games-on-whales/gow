ARG BASE_IMAGE=ghcr.io/games-on-whales/base:edge
#################################
FROM ${BASE_IMAGE} AS sdl-jstest-builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

ARG SDL_JS_TEST_VERSION=8a84a47209f96eb3994cf9f906ae072e828886bb
ENV SDL_JS_TEST_VERSION=${SDL_JS_TEST_VERSION}
RUN <<_BUILD_SDL_JSTEST
    set -e 

    apt-get update -y
    apt install -y --no-install-recommends \
      build-essential \
      cmake \
      libsdl2-dev \
      libncurses5-dev \
      git 

    git clone https://github.com/games-on-whales/sdl-jstest
    cd sdl-jstest
    git checkout ${SDL_JS_TEST_VERSION}
    git submodule init
    git submodule update
    mkdir build
    cd build
    cmake .. -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL2_JSTEST=ON
    make

_BUILD_SDL_JSTEST

#################################
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="3.15.14"
ENV GAMESCOPE_VERSION=$GAMESCOPE_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ARCHITECTURE=amd64
ENV DEB_BUILD_OPTIONS=noddebs

ARG PKGS_ROOT=/opt/gow

# x11-utils: contains xdpyinfo, which we use to know whether Xorg has started yet
# pulseaudio-utils: some apps can't play sound unless this package is installed
ARG REQUIRED_PACKAGES="\
    x11-utils \
    pulseaudio-utils \
    mesa-vulkan-drivers libgbm1 libgles2 libegl1 libgl1-mesa-dri \
    libnvidia-egl-wayland1 libnvidia-egl-gbm1 \
    fonts-noto-cjk \
    locales \
    gamescope \
    xwayland kitty nano \
    waybar fonts-font-awesome xdg-desktop-portal xdg-desktop-portal-gtk psmisc \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Some games with native Linux ports require en_US.UTF-8
# to be generated regardless of user locale settings
# see: https://github.com/games-on-whales/gow/pull/185
RUN locale-gen en_US.UTF-8

COPY configs /cfg

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/launch-comp.sh /opt/gow/launch-comp.sh
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh
COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends libsdl2-2.0-0 libncurses6 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=sdl-jstest-builder /sdl-jstest/build/sdl2-jstest /usr/local/bin/sdl2-jstest

# Add /usr/games/ to $PATH in order to be able to run gamescope
ENV PATH="/usr/games/:${PATH}"

#################################
# Install Sway
#################################
# We had lots of issues with Sway 1.10.1
# So we are manually reverting back to 1.9 from Ubuntu 24.04
RUN <<_INSTALL_SWAY
#!/bin/bash
set -e
curl -L -o sway.deb https://launchpad.net/ubuntu/+source/sway/1.9-1build2/+build/28013086/+files/sway_1.9-1build2_amd64.deb
apt update
apt install -y --no-install-recommends ./sway.deb
rm -rf /var/lib/apt/lists/* ./sway.deb
_INSTALL_SWAY

#################################
# Install MangoHuD
#################################
RUN <<_INSTALL_MANGO
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "flightlessmango/MangoHud" ".assets[]|select(.name|endswith(\".tar.gz\")).browser_download_url" "MangoHud.tar.gz"
tar xf MangoHud.tar.gz
cd MangoHud
tar xf MangoHud-package.tar
chmod +x ./mangohud-setup.sh && ./mangohud-setup.sh install
rm -rf /MangoHud*
_INSTALL_MANGO

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
