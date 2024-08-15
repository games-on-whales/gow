ARG BASE_IMAGE
#################################
FROM ${BASE_IMAGE} as sdl-jstest-builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

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
    git submodule init
    git submodule update
    mkdir build
    cd build
    cmake .. -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL2_JSTEST=ON
    make

_BUILD_SDL_JSTEST

#################################
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="3.14.2"
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
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

#################################
# GAMESCOPE
####

COPY <<-EOT $PKGS_ROOT/gamescope.control
Priority: optional
Standards-Version: 3.9.2

Section: misc
Package: gamescope-gow
Version: ${GAMESCOPE_VERSION}
Depends: libc6, libcap2, libdisplay-info1, libdrm2, libliftoff0, libsdl2-2.0-0, libstdc++6, libvulkan1, libwayland-client0, libwayland-server0, libwlroots12t64, libx11-6, libx11-xcb1, libx11-xcb1, libxcb1, libxcomposite1, libxdamage1, libxext6, libxfixes3, libxkbcommon0, libxmu6, libxrender1, libxres1, libxtst6, libxxf86vm1, xwayland, libcap2-bin
Replaces: gamescope, gamescope-core
Description: Manually built from git
EOT

# shellcheck disable=SC2086,DL3015,DL3013,DL3003
RUN <<_INSTALL_GAMESCOPE
    #!/bin/bash
    set -e

    # Dependencies
    DEV_PACKAGES="\
        git curl build-essential gcc pkg-config ninja-build meson cmake equivs libcap2-bin \
        libvulkan-dev libwayland-dev wayland-protocols libudev-dev libinput-dev libpixman-1-dev libseat-dev libssl-dev libcap-dev \
        libx11-dev libx11-xcb-dev libxdamage-dev libxxf86vm-dev libxres-dev libxmu-dev libx11-xcb-dev libxcomposite-dev libxtst-dev \
        libxrender-dev libxshmfence-dev libxkbfile-dev libxkbcommon-dev libxfont-dev libxcvt-dev libgl-dev \
        libxcb-icccm4-dev libxcb-res0-dev libxcb-ewmh-dev libxcb-composite0-dev glslang-tools libsdl2-dev libepoxy-dev \
        xserver-common libliftoff0 libwlroots12t64 mesa-common-dev libbenchmark-dev xwayland libdisplay-info1"
    apt-get update -y
    apt-get install -y --no-install-recommends $DEV_PACKAGES

    GAMESCOPE_SRC=/tmp/gamescope
    mkdir -p $GAMESCOPE_SRC
    cd $GAMESCOPE_SRC

    # Installing from apt will miss the pkgconfig .pc file, building manually
    git clone https://github.com/vcrhonek/hwdata.git
    cd hwdata
    ./configure
    make
    make install

    cd $GAMESCOPE_SRC
    git clone https://github.com/ValveSoftware/gamescope.git
    cd gamescope
    git checkout $GAMESCOPE_VERSION
    git submodule update --init
    # fake apt install
    equivs-build ${PKGS_ROOT}/gamescope.control
    dpkg -i gamescope-gow_${GAMESCOPE_VERSION}_all.deb

    meson setup --buildtype=release -Dpipewire=disabled -Denable_openvr_support=false build
    meson compile -C build
    meson install -C build --skip-subprojects

    # Add setcap as seen in: https://github.com/Plagman/gamescope/issues/497#issuecomment-1127110769
    install /usr/local/bin/gamescope /usr/games/gamescope
    setcap 'cap_sys_nice=eip' /usr/games/gamescope

    # Cleanup
    apt-mark auto $DEV_PACKAGES
    apt-get autoremove -y --purge
    rm -rf \
      /var/lib/apt/lists/* \
      $GAMESCOPE_SRC
_INSTALL_GAMESCOPE

#################################
# Install Sway
#################################
RUN apt-get update -y && \
    apt-get install -y sway xwayland kitty nano \
             waybar fonts-font-awesome  xdg-desktop-portal xdg-desktop-portal-gtk psmisc && \
    rm -rf /var/lib/apt/lists/*

COPY configs /cfg

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/launch-comp.sh /opt/gow/launch-comp.sh
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh
COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends libsdl2-2.0-0 libncurses6 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=sdl-jstest-builder /sdl-jstest/build/sdl2-jstest /usr/local/bin/sdl2-jstest

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
