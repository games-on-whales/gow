ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ghcr.io/games-on-whales/base-app:wolf-changes

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    wget p7zip-full \
	software-properties-common \
    retroarch \
    libretro* \
    libvulkan1 \
    mesa-* \
    fuse \
    libfuse2 \
"
RUN \
    echo "**** Install ESDE ****" && \
	    apt-get update && \
        wget -O /tmp/esde.deb https://gitlab.com/es-de/emulationstation-de/-/package_files/71412450/download && \
        apt install -y /tmp/esde.deb && \
		rm /tmp/esde.deb

# Install RetroArch
RUN \
    echo "**** Install RetroArch ****" && \
	apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent libusb-1.0-0 libglu1-mesa libaio1 libaio-dev && \
    # \
    # Install retroarch \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES

# Install PCSX2
RUN \
    echo "**** Install PCSX2 ****" && \
	add-apt-repository -y ppa:pcsx2-team/pcsx2-daily && \
    apt-get update && \
    apt-get install -y pcsx2-unstable
	
# Install WINE
RUN \
    echo "**** Install WINE ****" && \
	dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine32 wine64 winetricks

# Install XEMU
RUN \
    echo "**** Install XEMU ****" && \
	add-apt-repository -y ppa:mborgerson/xemu && \
    apt-get update && \
    apt-get install -y xemu && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
	
# Downloading RPCS3 AppImage 
RUN \
    echo "**** Downloading RPCS3 ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O rpcs3-emu.AppImage https://rpcs3.net/latest-appimage

# Downloading YUZU AppImage       
RUN \
    echo "**** Downloading YUZU ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O yuzu-emu.AppImage https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1373/yuzu-mainline-20230315-6d76a54d3.AppImage
        
COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
