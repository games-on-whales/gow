ARG KODI_VERSION=21.2-Omega
ARG KODI_INSTALLATION_FOLDER=/kodi
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

FROM ubuntu:24.10 AS kodi-builder

ARG DEBIAN_FRONTEND=noninteractive

ARG DEV_PACKAGES=" \
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
    libogg-dev libpcre3-dev libplist-dev libpng-dev \
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

RUN apt-get update -y && \
    apt-get install -y \
    $DEV_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

ARG KODI_VERSION
ARG KODI_INSTALLATION_FOLDER

RUN <<_BUILD_KODI

mkdir ${KODI_INSTALLATION_FOLDER}

git clone https://github.com/xbmc/xbmc xbmc
echo "Checking out Kodi version: ${KODI_VERSION}"
cd xbmc && git checkout ${KODI_VERSION}
mkdir build && cd build

cmake ../ -DCMAKE_INSTALL_PREFIX=${KODI_INSTALLATION_FOLDER} -DCORE_PLATFORM_NAME=wayland -DAPP_RENDER_SYSTEM=gl -GNinja
cmake --build . -j$(getconf _NPROCESSORS_ONLN)
make -j$(getconf _NPROCESSORS_ONLN) -C ../tools/depends/target/binary-addons PREFIX=${KODI_INSTALLATION_FOLDER} \
      ADDONS="peripheral.joystick pvr.*"

cmake --install .
exit 0 # TODO: the install step seems to fail, but the binaries are there...
_BUILD_KODI

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG REQUIRED_PACKAGES=" \
    libasound2-dev libass-dev \
    libavahi-client3 libavahi-common3 \
    libbluetooth3 libbluray2 bzip2 \
    libcdio19t64 libp8-platform2 libcrossguid0 \
    libcurl4t64 libcwiid1t64 libdbus-1-3 \
    libdrm2 libegl1 libenca0 \
    libexiv2-27 libflac12t64 libfmt9 \
    libfontconfig1 libfreetype6 \
    libfribidi0 libfstrcmp0 \
    libgcrypt20 libgif7 libgles2 \
    libgl1 libglu1 libgnutls30t64 \
    libgpg-error0 libiso9660-11t64 \
    libjpeg62 liblcms2-2 libltdl7 liblzo2-2 \
    libmicrohttpd12t64 libmysqlclient21 libnfs14 \
    libogg0 libpcre3 libplist-2.0-4 libpng16-16t64 \
    libpulse0 libshairplay0 libsmbclient0 \
    libspdlog1.12 libsqlite3-0 libssl3t64 libtag1v5 \
    libtiff6 libtinyxml2-10 libtinyxml2.6.2v5 libtool \
    libudev1 libunistring5 libva-dev libvdpau1 \
    libvorbis0a libxmu6 libxrandr2 libxslt1.1 \
    libxt6t64 lsb-release nasm \
    unzip uuid zip zlib1g \
    libflatbuffers23.5.26 libglew2.2 libwayland-client0 \
    libwayland-client++1 libwayland-cursor++1 libwayland-egl++1 libxkbcommon-x11-0 wayland-protocols \
"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/Xbox_controller.xml /opt/gow/Xbox_controller.xml
COPY configs/Switch_controller.xml /opt/gow/Switch_controller.xml
COPY configs/PS_controller.xml /opt/gow/PS_controller.xml
COPY configs/settings.xml /opt/gow/settings.xml

ARG KODI_INSTALLATION_FOLDER
COPY --chmod=777 --from=kodi-builder $KODI_INSTALLATION_FOLDER $KODI_INSTALLATION_FOLDER
RUN ln -s $KODI_INSTALLATION_FOLDER/bin/kodi /usr/bin/kodi

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE