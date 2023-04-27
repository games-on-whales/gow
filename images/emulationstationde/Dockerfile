ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ghcr.io/games-on-whales/base-app:wolf-changes

ARG DEBIAN_FRONTEND=noninteractive

# Install prereqs
RUN \
    echo "**** Install Prereqs and latest Mesa ****" && \
		apt-get update && \
		apt-get install -y software-properties-common gpg-agent wget p7zip-full libvulkan1 mesa-vulkan-drivers libglu1-mesa-dev fuse libfuse2 qtbase5-dev qt5-qmake ffmpeg x11-xserver-utils libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 && \
		add-apt-repository ppa:kisak/kisak-mesa && \
		apt-get update && \
		apt-get upgrade -y && \
	# Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install ES-DE
RUN \
    echo "**** Install ESDE ****" && \
	    apt-get update && \
        wget -O /tmp/esde.deb https://gitlab.com/es-de/emulationstation-de/-/package_files/71412450/download && \
        apt install -y /tmp/esde.deb && \
		rm /tmp/esde.deb && \
    # Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install RetroArch
RUN \
    echo "**** Install RetroArch ****" && \
		apt-get update && \
		apt-get install -y --no-install-recommends software-properties-common gpg-agent libusb-1.0-0 libglu1-mesa libaio1 libaio-dev && \
		add-apt-repository ppa:libretro/stable && \
		apt-get install -y retroarch libretro*  && \
    # Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*
		
# Install PCSX2
RUN \
    echo "**** Install PCSX2 ****" && \
		add-apt-repository -y ppa:pcsx2-team/pcsx2-daily && \
		apt-get update && \
		apt-get install -y pcsx2-unstable && \
    # Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install XEMU
RUN \
    echo "**** Install XEMU ****" && \
		add-apt-repository -y ppa:mborgerson/xemu && \
		apt-get update && \
		apt-get install -y xemu && \
    # Cleanup \
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
        wget -O yuzu-emu.AppImage https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1404/yuzu-mainline-20230414-e0895a858.AppImage

# Install Steam
RUN \
    echo "**** Install Steam ****" && \
		apt-get update && \
		apt-get install -y --no-install-recommends software-properties-common && \
		dpkg --add-architecture i386 && \
		add-apt-repository multiverse && \
		apt-get update && \
		apt-get install -y --no-install-recommends steam libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 && \
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
    echo "**** Permissions on Appimages ****" && \
        mkdir -p /Applications && \
        mv /tmp/*.AppImage /Applications && \
        chmod 777 /Applications/rpcs3-emu.AppImage && \
        chmod 777 /Applications/yuzu-emu.AppImage && \
        chmod a+x /Applications/yuzu-emu.AppImage && \
        chmod a+x /Applications/rpcs3-emu.AppImage

COPY configs/es/es_systems.xml /cfg/es/es_systems.xml        
COPY configs/retroarch/retroarch.cfg /cfg/retroarch/retroarch.cfg
COPY configs/rpcs3/Default.yml /cfg/rpcs3/Default.yml
COPY configs/rpcs3/CurrentSettings.ini /cfg/rpcs3/CurrentSettings.ini
COPY configs/pcsx2/PCSX2.ini /cfg/pcsx2/PCSX2.ini
COPY configs/xemu/xemu.toml /cfg/xemu/xemu.toml
COPY configs/yuzu/qt-config.ini /cfg/yuzu/qt-config.ini
COPY --chmod=777 scripts/custom_scripts/winecfg.sh /cfg/custom_scripts/winecfg.sh
COPY --chmod=777 scripts/custom_scripts/retroarch.sh /cfg/custom_scripts/retroarch.sh
COPY --chmod=777 scripts/custom_scripts/rpcs3.sh /cfg/custom_scripts/rpcs3.sh
COPY --chmod=777 scripts/custom_scripts/!Install_RPCS3_Firmware.sh /cfg/custom_scripts/!Install_RPCS3_Firmware.sh
COPY --chmod=777 scripts/custom_scripts/yuzu.sh /cfg/custom_scripts/yuzu.sh
COPY --chmod=777 scripts/custom_scripts/xemu.sh /cfg/custom_scripts/xemu.sh
COPY --chmod=777 scripts/custom_scripts/pcsx2.sh  /cfg/custom_scripts/pcsx2.sh
COPY --chmod=777 scripts/custom_scripts/steam.sh  /cfg/custom_scripts/steam.sh       
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-es.sh /opt/gow/startup-es.sh

ENV XDG_RUNTIME_DIR=/tmp/sockets

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
