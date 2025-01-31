ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

#GitHub REST query versioning
ARG GITHUB_REST_VERSION=2022-11-28

# Install prereqs
RUN \
    echo "**** Install Common Prereqs (Mesa/Vulkan/Fuse/QT/Misc) ****" && \
		apt-get update && \
		apt-get install -y \
            curl \
            ffmpeg \
            gpg-agent \
            jq \
            libdbus-1-3 \
            libegl1 \
            libglu1-mesa-dev \
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
            libaio-dev \
            libaio1t64 \
            libglu1-mesa \
            libusb-1.0-0 \
            && \
        add-apt-repository ppa:libretro/stable && \
        apt-get update && \
		apt-get install -y retroarch && \
    # Cleanup \
        apt-get remove -y python3-six && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*


RUN <<_INSTALL_EMULATORS
set -e

EMULATORS_DIR=/Applications
mkdir -p $EMULATORS_DIR
cd $EMULATORS_DIR

github_download(){
    curl -H "X-GitHub-Api-Version: "$(GITHUB_REST_VERSION)"" \
        https://api.github.com/repos/$1/releases/latest | \
        jq '.assets[]|select(.name|endswith(".AppImage")).browser_download_url' | \
        xargs wget -O $2
}

echo "**** Downloading PCSX2 AppImage ****"
github_download "PCSX2/pcsx2" "pcsx2-emu.AppImage"

echo "**** Downloading XEMU AppImage ****"
github_download "xemu-project/xemu" "xemu-emu.AppImage"

echo "**** Downloading RPCS3 AppImage ****"
github_download "rpcs3/rpcs3-binaries-linux" "rpcs3-emu.AppImage"

echo "**** Downloading CEMU AppImage ****"
github_download "cemu-project/Cemu" "cemu-emu.AppImage"

echo "**** Downloading Dolphin AppImage ****"
# TODO: This is some randomly found AppImage. Need to find something more official
github_download "qurious-pixel/dolphin" "dolphin-emu.AppImage"

chmod -v -R 777 $EMULATORS_DIR
chmod -v -R a+x $EMULATORS_DIR
_INSTALL_EMULATORS

COPY --chmod=777 launchers /Applications/launchers
ENV PATH="/Applications/launchers:${PATH}"

RUN \
    echo "**** Preparing /bioses for symlinking ****" && \
        mkdir -pm755 /bioses

RUN \
    echo "**** Preparing /ROMs for symlinking ****" && \
        mkdir -pm755 /ROMs

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
