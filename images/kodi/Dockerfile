ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

#TODO: Build this madness in a different Dockerfile and just copy the binary
ARG REQUIRED_PACKAGES=" \
    debhelper autoconf autoconf automake \
    autopoint gettext autotools-dev cmake \
    curl default-jre doxygen gawk gcc gdc \
    gperf libasound2-dev libass-dev \
    libavahi-client-dev libavahi-common-dev \
    libbluetooth-dev libbluray-dev libbz2-dev \
    libcdio-dev libp8-platform-dev libcrossguid-dev \
    libcurl4-openssl-dev libcwiid-dev libdbus-1-dev \
    libdrm-dev libegl1-mesa-dev libenca-dev \
    libexiv2-dev libflac-dev libfmt-dev \
    libfontconfig-dev libfreetype6-dev \
    libfribidi-dev libfstrcmp-dev \
    libgcrypt-dev libgif-dev libgles2-mesa-dev \
    libgl1-mesa-dev libglu1-mesa-dev libgnutls28-dev \
    libgpg-error-dev libgtest-dev libiso9660-dev \
    libjpeg-dev liblcms2-dev libltdl-dev liblzo2-dev \
    libmicrohttpd-dev libmysqlclient-dev libnfs-dev \
    libogg-dev libpcre2-dev libplist-dev libpng-dev \
    libpulse-dev libshairplay-dev libsmbclient-dev \
    libspdlog-dev libsqlite3-dev libssl-dev libtag1-dev \
    libtiff5-dev libtinyxml-dev libtinyxml2-dev libtool \
    libudev-dev libunistring-dev libva-dev libvdpau-dev \
    libvorbis-dev libxmu-dev libxrandr-dev libxslt1-dev \
    libxt-dev lsb-release meson nasm ninja-build \
    python3-dev python3-pil python3-pip rapidjson-dev \
    swig unzip uuid-dev zip zlib1g-dev git \
    libflatbuffers-dev libglew-dev libwayland-dev \
    libxkbcommon-dev waylandpp-dev wayland-protocols \
    "

# Build Kodi from source
RUN apt-get update && \
    apt-get install -y $REQUIRED_PACKAGES && \
    git clone https://github.com/xbmc/xbmc kodi && \
    apt-get update && \
    mkdir kodi-build && \
    cd kodi-build && \
    cmake ../kodi -DCMAKE_INSTALL_PREFIX=/usr/local -DCORE_PLATFORM_NAME=wayland -DAPP_RENDER_SYSTEM=gl && \
    cmake --build . -- VERBOSE=1 -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    #clean up
    cd .. && \
    rm -R kodi/ && \
    rm -R kodi-build/

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE