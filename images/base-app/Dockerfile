ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="experiments"
ENV GAMESCOPE_VERSION=$GAMESCOPE_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ARCHITECTURE=amd64
ENV DEB_BUILD_OPTIONS=noddebs

ARG PKGS_ROOT=/opt/gow
COPY --chmod=777 packages $PKGS_ROOT

# x11-utils: contains xdpyinfo, which we use to know whether Xorg has started yet
# pulseaudio-utils: some apps can't play sound unless this package is installed
ARG REQUIRED_PACKAGES="\
    x11-utils \
    pulseaudio-utils \
    mesa-vulkan-drivers libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

#################################
# GAMESCOPE
####
# shellcheck disable=SC2086,DL3015,DL3013,DL3003
RUN <<_INSTALL_GAMESCOPE
    #!/bin/bash
    set -e

    # Dependencies
    DEV_PACKAGES="\
        git build-essential gcc pkg-config ninja-build meson cmake equivs libcap2-bin \
        libpipewire-0.3-dev libvulkan-dev libwayland-dev libudev-dev libinput-dev libpixman-1-dev libseat-dev libssl-dev libcap-dev \
        libx11-dev libx11-xcb-dev libxdamage-dev libxxf86vm-dev libxres-dev libxmu-dev libx11-xcb-dev libxcomposite-dev libxtst-dev \
        libxrender-dev libxshmfence-dev libxkbfile-dev libxkbcommon-dev libxfont-dev libxcvt-dev libgl-dev \
        libxcb-icccm4-dev libxcb-res0-dev libxcb-composite0-dev glslang-tools libsdl2-dev libepoxy-dev \
        xserver-common libliftoff0 libwlroots10 mesa-common-dev libbenchmark-dev"
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

    # Installing from APT will pull an old version, gamescope requires >=1.27
    cd $GAMESCOPE_SRC
    git clone -b 1.31 --depth=1 https://gitlab.freedesktop.org/wayland/wayland-protocols.git
    cd wayland-protocols
    meson setup --buildtype=release build
    meson compile -C build
    meson install -C build

    # Installing xwayland
    cd $GAMESCOPE_SRC
    git clone -b xwayland-23.1.1 --depth=1 https://gitlab.freedesktop.org/xorg/xserver.git
    cd xserver
    mkdir subprojects
    meson setup -Dxvfb=false -Ddocs=false build
    meson compile -C build
    meson install -C build
    # fake apt install
    equivs-build ${PKGS_ROOT}/xwayland.control
    dpkg -i xwayland-gow_23.1.1_all.deb

    cd $GAMESCOPE_SRC
    git clone https://github.com/drakulix/gamescope.git
    cd gamescope
    git checkout $GAMESCOPE_VERSION
    git submodule update --init
    # fake apt install
    equivs-build ${PKGS_ROOT}/gamescope.control
    dpkg -i gamescope-gow_3.12.0-beta3_all.deb

    meson setup --buildtype=release build
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

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
