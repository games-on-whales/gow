ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

# Install prereqs
RUN \
    echo "**** Install Prereqs (Mesa/Vulkan/Fuse/QT/Misc) ****" && \
        apt-get update && \
        apt-get install -y \
            ffmpeg \
            gpg-agent \
            libdbus-1-3 \
            libegl1 \
            libglu1-mesa-dev \
            libgstreamer-gl1.0-0 \
            libgtk-3-0 \
            libsdl2-2.0-0 \
            libvulkan1 \
            p7zip-full \
            python3-six \
            qt5-qmake \
            qtbase5-dev \
            software-properties-common \
            wget \
            x11-xserver-utils \
            && \
	# Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install RetroArch
RUN \
    echo "**** Install RetroArch ****" && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            gpg-agent \
            libaio-dev \
            libaio1 \
            libglu1-mesa \
            libusb-1.0-0 \
            software-properties-common \
            && \
        add-apt-repository ppa:libretro/stable && \
        apt-get update && \
		apt-get install -y retroarch && \
    # Cleanup \
        apt-get remove -y python3-six && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install pegasus
RUN  <<_INSTALL_PEGASUS
  #!/bin/bash
  set -e

  echo "**** Installing pegasus ****"
  apt-get update -y
  apt-get install -y --no-install-recommends jq curl

  # Pegasus still requires libssl1.1, but ubuntu switched to libssl3. Need to manually install it.
  # TODO: Doing this could be a terrible idea (it does work)
  wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb --output-document=libssl1.1.deb
  apt-get install -y ./libssl1.1.deb

  # Pegasus doesn't tag releases, they have a rolling weekly release
  # so we have to parse the Github APIs to get the link
  curl -s https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous | \
  jq -r '.assets[] | select(.name | contains(".deb")) | .browser_download_url' | \
  xargs curl -fsSL -o pegasus.deb

  apt-get install -y ./pegasus.deb

  # Cleanup
  rm pegasus.deb libssl1.1.deb
  apt-get remove -y jq curl
  apt-get autoremove -y
  rm -rf /var/lib/apt/lists/*
_INSTALL_PEGASUS

ARG PCS2_APP_IMAGE_URL=https://github.com/PCSX2/pcsx2/releases/download/v1.7.5232/pcsx2-v1.7.5232-linux-appimage-x64-Qt.AppImage
ARG XEMU_APP_IMAGE_URL=https://github.com/xemu-project/xemu/releases/download/v0.7.117/xemu-v0.7.117-x86_64.AppImage
ARG RPCS3_APP_IMAGE_URL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-9c354ee269779c5b473b39d313cbe1305040d138/rpcs3-v0.0.30-15970-9c354ee2_linux64.AppImage
ARG CEMU_APP_IMAGE_URL=https://github.com/cemu-project/Cemu/releases/download/v2.0-61/Cemu-2.0-61-x86_64.AppImage
ARG DOLPHIN_APP_IMAGE_URL=https://github.com/qurious-pixel/dolphin/releases/download/continuous/Dolphin_Emulator-x86_64.AppImage
# TODO: This is some randomly found AppImage. Need to find something more official

ARG APP_IMAGES_FOLDER=/Applications
RUN <<_DOWNLOAD_APP_IMAGES
  #!/bin/bash
  set -e

  echo "**** Downloading Emulators AppImages ****"
  mkdir -p "${APP_IMAGES_FOLDER}"

  wget -O "${APP_IMAGES_FOLDER}"/pcsx2-emu-Qt.AppImage "${PCS2_APP_IMAGE_URL}"
  wget -O "${APP_IMAGES_FOLDER}"/rpcs3-emu.AppImage "${RPCS3_APP_IMAGE_URL}"
  wget -O "${APP_IMAGES_FOLDER}"/xemu-emu.AppImage "${XEMU_APP_IMAGE_URL}"
  wget -O "${APP_IMAGES_FOLDER}"/cemu-emu.AppImage "${CEMU_APP_IMAGE_URL}"
  wget -O "${APP_IMAGES_FOLDER}"/dolphin-emu.AppImage "${DOLPHIN_APP_IMAGE_URL}"

  # Dolphin extra deps
  apt-get update -y
  apt-get install -y \
  qtbase5-dev \
  qtbase5-dev-tools \
  qt6-base-dev \
  qt6-base-dev-tools

  chmod -v -R 777 /Applications/
  chmod -v -R a+x /Applications/

  # Cleanup
  apt-get autoremove -y
  rm -rf /var/lib/apt/lists/*
_DOWNLOAD_APP_IMAGES

# Copy config files
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

# Copy Pegasus related files
COPY scripts/launchers/*.sh /bin/
COPY scripts/tools/*.sh /bin/
COPY configs /cfg

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
