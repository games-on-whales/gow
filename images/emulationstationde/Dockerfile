ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ghcr.io/games-on-whales/base-app:sha-adc0a26

ARG DEBIAN_FRONTEND=noninteractive

# Install prereqs
RUN \
    echo "**** Install Prereqs (Mesa/Vulkan/Fuse/QT/Misc) ****" && \
		apt-get update && \
		apt-get install -y software-properties-common gpg-agent wget p7zip-full libvulkan1 mesa-vulkan-drivers libglu1-mesa-dev fuse libfuse2 qtbase5-dev qt5-qmake ffmpeg x11-xserver-utils libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 && \
		add-apt-repository ppa:kisak/kisak-mesa && \
		apt-get update && \
		apt-get upgrade -y && \
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
		apt-get install -y --no-install-recommends software-properties-common gpg-agent libusb-1.0-0 libglu1-mesa libaio1 libaio-dev && \
		add-apt-repository ppa:libretro/stable && \
		apt-get update && \
		apt-get install -y retroarch && \
    # Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*
		
# Downloading PCSX2 AppImage
RUN \
    echo "**** Downloading PCSX2 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O pcsx2-emu-Qt.AppImage https://github.com/PCSX2/pcsx2/releases/download/v1.7.4478/pcsx2-v1.7.4478-linux-AppImage-64bit-Qt.AppImage

# Downloading XEMU AppImage
RUN \
    echo "**** Downloading XEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O xemu-emu.AppImage https://github.com/xemu-project/xemu/releases/download/v0.7.88/xemu-v0.7.88-x86_64.AppImage
	
# Downloading RPCS3 AppImage 
RUN \
    echo "**** Downloading RPCS3 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O rpcs3-emu.AppImage https://rpcs3.net/latest-appimage

# Downloading YUZU AppImage       
RUN \
    echo "**** Downloading YUZU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O yuzu-emu.AppImage https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1433/yuzu-mainline-20230514-756203c81.AppImage

# Install Steam
RUN \
    echo "**** Install Steam ****" && \
		apt-get update && \
		apt-get install -y --no-install-recommends software-properties-common && \
		dpkg --add-architecture i386 && \
		add-apt-repository multiverse && \
		apt-get update && \
		apt-get install -y --no-install-recommends steam && \
	# Cleanup \
	    apt-get remove -y software-properties-common && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install WINE
RUN \
    echo "**** Install WINE and Winetricks ****" && \
		dpkg --add-architecture i386 && \
		apt-get update && \
		mkdir -pm755 /etc/apt/keyrings && \
		apt-get install -y --no-install-recommends software-properties-common && \
		wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
		wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources && \
		apt-get update && \
		apt-get install -y winehq-stable cabextract && \
		wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
		chmod +x winetricks && \
		mv -v winetricks /usr/local/bin && \
    # Cleanup \
		apt-get remove -y software-properties-common gpg-agent && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

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
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-es.sh /opt/gow/startup-es.sh

ENV XDG_RUNTIME_DIR=/tmp/sockets

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
