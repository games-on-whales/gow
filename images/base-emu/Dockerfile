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
		
# Downloading PCSX2 AppImage
RUN \
    echo "**** Downloading PCSX2 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		curl -H "X-GitHub-Api-Version: "$(GITHUB_REST_VERSION)"" \
        https://api.github.com/repos/PCSX2/pcsx2/releases/latest | \
        jq '.assets[]|select(.name|endswith(".AppImage"))'.browser_download_url | \
        xargs wget -O pcsx2-emu-Qt.AppImage 

# Downloading XEMU AppImage
RUN \
    echo "**** Downloading XEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		curl -H "X-GitHub-Api-Version: "$(GITHUB_REST_VERSION)"" \
        https://api.github.com/repos/xemu-project/xemu/releases/latest | \
        jq '.assets[]|select(.name|endswith(".AppImage"))|select(.name|contains("dbg")|not).browser_download_url' | \
        xargs wget -O xemu-emu.AppImage 
	
# Downloading RPCS3 AppImage
# Get the latest binary and download curl-> json -> wget
RUN \
    echo "**** Downloading RPCS3 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
 	curl -H "X-GitHub-Api-Version: "$(GITHUB_REST_VERSION)"" \
        https://api.github.com/repos/rpcs3/rpcs3-binaries-linux/releases/latest | \
    jq '.assets[]|select(.name|endswith(".AppImage")).browser_download_url' | \
    xargs wget -O rpcs3-emu.AppImage

# Install Cemu
ARG CEMU_APP_IMAGE_URL=https://github.com/cemu-project/Cemu/releases/download/v2.0-61/Cemu-2.0-61-x86_64.AppImage
RUN \
    echo "**** Downloading CEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        curl -H "X-GitHub-Api-Version: "$(GITHUB_REST_VERSION)"" \
        https://api.github.com/repos/cemu-project/Cemu/releases/latest | \
        jq '.assets[]|select(.name|endswith(".AppImage")).browser_download_url' | \
        xargs wget -O cemu-emu.AppImage

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
    echo "**** Preparing /bioses for symlinking ****" && \
        mkdir -pm755 /bioses

RUN \
    echo "**** Preparing /ROMs for symlinking ****" && \
        mkdir -pm755 /ROMs

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
