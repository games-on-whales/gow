ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG MESA_VERSION=23.0.3
ENV MESA_VERSION=$MESA_VERSION
ARG INTEL_MEDIA_VERSION=23.1.5
ENV INTEL_MEDIA_VERSION=$INTEL_MEDIA_VERSION
ARG LIBVA_VERSION=2.18.0
ENV LIBVA_VERSION=$LIBVA_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ARCHITECTURE=amd64
ENV DEB_BUILD_OPTIONS=noddebs

ENV SOURCE_PATH=/sources
ENV INCDIR=/usr/include
ENV LIBDIR=/usr/lib/x86_64-linux-gnu
ENV BINDIR=/usr/bin
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:${SOURCE_PATH}/lib/pkgconfig
ENV PKGS_ROOT=/opt/gow/packages
RUN mkdir -p ${INCDIR} ${SOURCE_PATH}

COPY --chmod=777 packages $PKGS_ROOT

# Take a deep breath...
# We have to do this all in one go because we don't want the dev packages to be in the final build
ENV CCACHE_DIR=/cache/ccache
RUN <<_INSTALL_GPU_DRIVERS
    #!/bin/bash
    set -e

    DEV_PACKAGES=" \
        apt-transport-https curl wget git bison flex \
        build-essential gcc ninja-build pkg-config \
        debhelper gnupg devscripts mmv equivs nasm subversion dh-autoreconf \
        libvulkan-dev libpciaccess-dev libwayland-dev libwayland-egl-backend-dev libzstd-dev \
        libxext-dev libxfixes-dev libx11-xcb-dev libxcb-dri3-dev libgl-dev libdrm-dev libigdgmm-dev libglvnd-dev \
        zlib1g-dev llvm-15-dev libudev-dev libelf-dev libexpat1-dev \
        python3-pip"
    RUNTIME_DEPS=" \
     python3 glslang-tools \
     libwayland-client0 libwayland-server0 wayland-protocols
     libx11-xcb1 libxcb-dri3-0 libxcb-present0 libxcb-randr0 libxcb-shm0 libxcb-sync1 libxcb-xfixes0 libxcb1 libxshmfence1"
    PY_PACKAGES="ninja meson cmake mako"
    apt-get update -y
    apt-get install -y --no-install-recommends $DEV_PACKAGES $RUNTIME_DEPS
    python3 -m pip install --no-cache-dir $PY_PACKAGES

    # GMMLIB (provides libigdgmm12 required by intel-media)
    cd ${SOURCE_PATH}
    git clone -b intel-gmmlib-22.3.5 --depth=1 https://github.com/intel/gmmlib.git
    cd gmmlib
    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/ -DRUN_TEST_SUITE=OFF ..
    make -j$(nproc) && make install
    cd ${SOURCE_PATH}

    # LIBVA (Required by mesa and intel-media)
    cd ${SOURCE_PATH}
    git clone -b ${LIBVA_VERSION} --depth=1 https://github.com/intel/libva.git
    cd libva
    ./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
    ./configure \
        --enable-drm \
        --enable-glx \
        --enable-x11 \
        --enable-wayland \
        --disable-docs
    make -j$(nproc)
    make install
    # fake apt install
    equivs-build ${PKGS_ROOT}/libva.control
    dpkg -i libva-dev_${LIBVA_VERSION}_all.deb

    # Intel MEDIA-DRIVER
    # See the instructions at: https://github.com/intel/media-driver/wiki/How-to-build-and-use-media-driver
    cd ${SOURCE_PATH}
    git clone -b intel-media-${INTEL_MEDIA_VERSION} --depth=1 https://github.com/intel/media-driver.git
    cd media-driver
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/ \
          -DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu \
          -DENABLE_KERNELS=ON \
          -DENABLE_NONFREE_KERNELS=ON \
          ..
    make -j$(nproc)
    make install
    install /usr/local/lib/dri/iHD_drv_video.so /usr/lib/x86_64-linux-gnu/dri/iHD_drv_video.so
    # fake apt install
    equivs-build ${PKGS_ROOT}/intel-media.control
    dpkg -i intel-media-driver_${INTEL_MEDIA_VERSION}_all.deb

    # MESA
    # Minimal libs for AMD and Intel
    cd ${SOURCE_PATH}
    git clone -b mesa-${MESA_VERSION} --depth=1 https://gitlab.freedesktop.org/mesa/mesa.git
    # disable the broken hevc packed header
    MESA_VA_PIC="mesa/src/gallium/frontends/va/picture.c"
    MESA_VA_CONF="mesa/src/gallium/frontends/va/config.c"
    sed -i 's|handleVAEncPackedHeaderParameterBufferType(context, buf);||g' ${MESA_VA_PIC}
    sed -i 's|handleVAEncPackedHeaderDataBufferType(context, buf);||g' ${MESA_VA_PIC}
    sed -i 's|if (u_reduce_video_profile(ProfileToPipe(profile)) == PIPE_VIDEO_FORMAT_HEVC)|if (0)|g' ${MESA_VA_CONF}
    # force reporting all packed headers are supported
    sed -i 's|value = VA_ENC_PACKED_HEADER_NONE;|value = 0x0000001f;|g' ${MESA_VA_CONF}
    sed -i 's|if (attrib_list\[i\].type == VAConfigAttribEncPackedHeaders)|if (0)|g' ${MESA_VA_CONF}
    meson setup mesa mesa_build \
        --prefix=/usr/ \
        --buildtype=release \
        --wrap-mode=nofallback \
        -Db_ndebug=true \
        -Db_lto=false \
        -Dplatforms=wayland \
        -Dgallium-drivers=radeonsi \
        -Dvulkan-drivers=amd,intel \
        -Ddri3=enabled \
        -Degl=enabled \
        -Dgallium-extra-hud=false -Dgallium-nine=false \
        -Dgallium-omx=disabled -Dgallium-vdpau=disabled -Dgallium-xa=disabled -Dgallium-opencl=disabled \
        -Dgallium-va=enabled \
        -Dvideo-codecs=h264dec,h264enc,h265dec,h265enc \
        -Dgbm=enabled \
        -Dgles1=disabled \
        -Dgles2=enabled \
        -Dopengl=true \
        -Dglvnd=true \
        -Dglx=disabled \
        -Dlibunwind=disabled \
        -Dllvm=enabled \
        -Dlmsensors=disabled \
        -Dosmesa=false \
        -Dshared-glapi=enabled \
        -Dvalgrind=disabled \
        -Dtools=[] \
        -Dzstd=enabled \
        -Dmicrosoft-clc=disabled
    meson configure mesa_build
    ninja -C mesa_build install
    # fake apt install
    equivs-build ${PKGS_ROOT}/mesa.control
    dpkg -i mesa-vulkan-drivers_${MESA_VERSION}_all.deb

    # Final cleanup stage
    python3 -m pip uninstall -y --no-cache-dir $PY_PACKAGES
    apt-get remove -y --purge $DEV_PACKAGES
    apt-get autoremove -y --purge
    # We can now safely delete the repo + builds
    rm -rf  \
    $SOURCE_PATH \
    /var/lib/apt/lists/*
_INSTALL_GPU_DRIVERS


ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig


#################################
# GAMESCOPE
####
ARG GAMESCOPE_VERSION=acef4c24edaecad642b1d4c046fd0afea0d3f09f
ENV GAMESCOPE_VERSION=$GAMESCOPE_VERSION

RUN <<_INSTALL_GAMESCOPE
    #!/bin/bash
    set -e

    # Dependencies
    DEV_PACKAGES="\
        git build-essential gcc pkg-config python3 python3-pip equivs libcap2-bin \
        libpipewire-0.3-dev libvulkan-dev libwayland-dev libudev-dev libinput-dev libpixman-1-dev libseat-dev libssl-dev libcap-dev \
        libx11-dev libx11-xcb-dev libxdamage-dev libxxf86vm-dev libxres-dev libxmu-dev libx11-xcb-dev libxcomposite-dev libxtst-dev \
        libxrender-dev libxshmfence-dev libxkbfile-dev libxkbcommon-dev libxfont-dev libxcvt-dev libgl-dev \
        libxcb-icccm4-dev libxcb-res0-dev libxcb-composite0-dev glslang-tools libsdl2-dev libepoxy-dev"
    RUNTIME_DEPS="xserver-common libliftoff0 libwlroots10"
    PY_PACKAGES="ninja meson cmake"
    apt-get update -y
    apt-get install -y --no-install-recommends $DEV_PACKAGES $RUNTIME_DEPS
    python3 -m pip install --no-cache-dir $PY_PACKAGES


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
    dpkg -i xwayland_23.1.1_all.deb

    cd $GAMESCOPE_SRC
    git clone https://github.com/ValveSoftware/gamescope.git
    cd gamescope
    git checkout $GAMESCOPE_VERSION
    git submodule update --init
    # fake apt install
    equivs-build ${PKGS_ROOT}/gamescope.control
    dpkg -i gamescope-core_3.12.0-beta3_all.deb

    meson setup --buildtype=release build
    meson compile -C build
    meson install -C build

    # Add setcap as seen in: https://github.com/Plagman/gamescope/issues/497#issuecomment-1127110769
    install /usr/local/bin/gamescope /usr/games/gamescope
    setcap 'cap_sys_nice=eip' /usr/games/gamescope

    # Cleanup
    python3 -m pip uninstall -y --no-cache-dir $PY_PACKAGES
    apt-get remove -y --purge $DEV_PACKAGES
    apt-get autoremove -y --purge
    rm -rf \
      /var/lib/apt/lists/* \
      $GAMESCOPE_SRC
_INSTALL_GAMESCOPE

COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

# x11-utils: contains xdpyinfo, which we use to know whether Xorg has started yet
# pulseaudio-utils: some apps can't play sound unless this package is installed
ARG REQUIRED_PACKAGES="\
    x11-utils \
    pulseaudio-utils \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
