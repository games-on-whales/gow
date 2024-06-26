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
		apt-get install -y software-properties-common gpg-agent wget p7zip-full libvulkan1 libglu1-mesa-dev qtbase5-dev qt5-qmake ffmpeg x11-xserver-utils libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 python3-six && \
	# Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Downloading ES-DE AppImage
RUN \
    echo "**** Downloading ESDE AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O esde.AppImage https://gitlab.com/es-de/emulationstation-de/-/package_files/76389058/download
		
# Install RetroArch
RUN \
    echo "**** Install RetroArch ****" && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            gpg-agent \
            libaio-dev \
            libglu1-mesa \
            libusb-1.0-0 \
            software-properties-common \
            libaio1t64 \
            && \
        add-apt-repository ppa:libretro/testing && \
        apt-get update && \
		apt-get install -y retroarch && \
    # Cleanup \
        apt-get remove -y python3-six && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*
		
# Downloading PCSX2 AppImage
RUN \
    echo "**** Downloading PCSX2 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O pcsx2-emu-Qt.AppImage https://github.com/PCSX2/pcsx2/releases/download/v1.7.4558/pcsx2-v1.7.4558-linux-AppImage-64bit-Qt.AppImage

# Downloading XEMU AppImage
RUN \
    echo "**** Downloading XEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O xemu-emu.AppImage https://github.com/xemu-project/xemu/releases/download/v0.7.92/xemu-v0.7.92-x86_64.AppImage
	
# Downloading RPCS3 AppImage
ARG RPCS3_APP_IMAGE_URL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-47fcb9562fd531350f7d9c847dda322c5f50d56d/rpcs3-v0.0.29-15807-47fcb956_linux64.AppImage
RUN \
    echo "**** Downloading RPCS3 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O rpcs3-emu.AppImage "${RPCS3_APP_IMAGE_URL}"

# Install Cemu
ARG CEMU_APP_IMAGE_URL=https://github.com/cemu-project/Cemu/releases/download/v2.0-61/Cemu-2.0-61-x86_64.AppImage
RUN \
    echo "**** Downloading CEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O cemu-emu.AppImage "${CEMU_APP_IMAGE_URL}"

# Install Dolphin-emu
ARG DOLPHIN_APP_IMAGE_URL=https://github.com/qurious-pixel/dolphin/releases/download/continuous/Dolphin_Emulator-x86_64.AppImage
# TODO: This is some randomly found AppImage. Need to find something more official
RUN \
    echo "**** Installing Dolphin Emulator ****" && \
        apt-get update && \
        apt-get install -y \
            qtbase5-dev \
            qtbase5-dev-tools \
            qt6-base-dev \
            qt6-base-dev-tools && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O dolphin-emu.AppImage "${DOLPHIN_APP_IMAGE_URL}"

RUN \
    echo "**** Preparing /Applications for symlinking ****" && \
        mkdir -p /Applications && \
        mv /tmp/*.AppImage /Applications && \
		chmod -v -R 777 /Applications/ && \
		chmod -v -R a+x /Applications/
		
RUN \
    echo "**** Preparing /media for EmulationStation ****" && \
        mkdir -pm777 /media
		
RUN \
    echo "**** Preparing /bioses for symlinking ****" && \
        mkdir -pm755 /bioses

RUN \
    echo "**** Preparing /ROMs for symlinking ****" && \
        mkdir -pm755 /ROMs

COPY configs/ /cfg/        
COPY --chmod=777 scripts/custom_scripts/ /cfg/custom_scripts/
COPY --chmod=777 scripts/startup.sh /etc/cont-init.d/setup-de.sh
COPY --chmod=777 scripts/startup-es.sh /opt/gow/startup-app.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
