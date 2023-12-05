ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="3.13.16"
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
        libvulkan-dev libudev-dev libinput-dev libpixman-1-dev libseat-dev libssl-dev libcap-dev \
        libx11-dev libx11-xcb-dev libxdamage-dev libxxf86vm-dev libxres-dev libxmu-dev libx11-xcb-dev libxcomposite-dev libxtst-dev \
        libxrender-dev libxshmfence-dev libxkbfile-dev libxkbcommon-dev libxfont-dev libxcvt-dev libgl-dev \
        libxcb-icccm4-dev libxcb-res0-dev libxcb-composite0-dev glslang-tools libsdl2-dev libepoxy-dev \
        xserver-common libliftoff0 libwlroots10 mesa-common-dev libbenchmark-dev libexpat1-dev libxml2-dev libxcb-ewmh-dev"
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

    # Installing from APT will pull an old version, gamescope requires >=1.32
    cd $GAMESCOPE_SRC
    git clone -b 1.32 --depth=1 https://gitlab.freedesktop.org/wayland/wayland-protocols.git
    cd wayland-protocols
    meson setup --buildtype=release build
    meson compile -C build
    meson install -C build

    # Installing from APT will pull an old version, gamescope requires wayland-server>=1.22
    cd $GAMESCOPE_SRC
    git clone -b 1.22.0 --depth=1 https://gitlab.freedesktop.org/wayland/wayland.git
    cd wayland
    meson setup --buildtype=release -Ddtd_validation=false -Ddocumentation=false -Dtests=false build
    meson compile -C build
    meson install -C build

    # Vulkan headers
    git clone -b v1.3.272 --depth=1 https://github.com/KhronosGroup/Vulkan-Headers.git
    cd Vulkan-Headers/
    cmake -S . -B build/
    cmake --install build

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
    git clone https://github.com/ValveSoftware/gamescope.git
    cd gamescope
    git checkout $GAMESCOPE_VERSION
    git submodule update --init
    # fake apt install
    equivs-build ${PKGS_ROOT}/gamescope.control
    dpkg -i gamescope-gow_3.13.16_all.deb

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

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
