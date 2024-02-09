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
# add-apt-repository ppa:libretro/stable && \
#            libretro-core-info \
#            libretro-frontend \
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
        add-apt-repository ppa:libretro/testing && \
        apt-get update && \
		apt-get install -y retroarch && \
    # Cleanup \
        apt-get remove -y python3-six && \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Downloading PCSX2 AppImage
ARG PCS2_APP_IMAGE_URL=https://github.com/PCSX2/pcsx2/releases/download/v1.7.5232/pcsx2-v1.7.5232-linux-appimage-x64-Qt.AppImage
RUN \
    echo "**** Downloading PCSX2 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O pcsx2-emu-Qt.AppImage "${PCS2_APP_IMAGE_URL}"

# Downloading XEMU AppImage
ARG XEMU_APP_IMAGE_URL=https://github.com/xemu-project/xemu/releases/download/v0.7.117/xemu-v0.7.117-x86_64.AppImage
RUN \
    echo "**** Downloading XEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O xemu-emu.AppImage "${XEMU_APP_IMAGE_URL}"

# Downloading RPCS3 AppImage
# ARG RPCS3_APP_IMAGE_URL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-98b764223285b2b1d474ece51027b936819adf46/rpcs3-v0.0.29-15813-98b76422_linux64.AppImage
ARG RPCS3_APP_IMAGE_URL=https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-9c354ee269779c5b473b39d313cbe1305040d138/rpcs3-v0.0.30-15970-9c354ee2_linux64.AppImage
RUN \
    echo "**** Downloading RPCS3 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O rpcs3-emu.AppImage "${RPCS3_APP_IMAGE_URL}"

# Downloading YUZU AppImage
# ARG YUZU_APP_IMAGE_URL=https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1657/yuzu-mainline-20231220-3cff46c98.AppImage
# ARG YUZU_APP_IMAGE_URL=https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1675/yuzu-mainline-20240107-ce8c1867d.AppImage
ARG YUZU_APP_IMAGE_URL=https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1687/yuzu-mainline-20240119-5aab1b86c.AppImage
RUN \
    echo "**** Downloading YUZU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O yuzu-emu.AppImage "${YUZU_APP_IMAGE_URL}"

# Install Dolphin-emu
# ARG DOLPHIN_APP_IMAGE_URL=https://github.com/project-slippi/Ishiiruka/releases/download/v3.3.1/Slippi_Online-x86_64.AppImage
# ARG DOLPHIN_APP_IMAGE_URL=https://github.com/lucasmz1/Dolphin_emu_Appimage/releases/download/continuous-stable/Dolphin_Emulator-x86_64.AppImage
ARG DOLPHIN_APP_IMAGE_URL=https://github.com/qurious-pixel/dolphin/releases/download/continuous/Dolphin_Emulator-x86_64.AppImage
# TODO: This is some randomly found AppImage. Need to find something more official
RUN \
    echo "**** Downloading Dolphin AppImage ****" && \
        apt-get update && \
        apt-get install -y \
            qtbase5-dev \
            qtbase5-dev-tools \
            qt6-base-dev \
            qt6-base-dev-tools && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O dolphin-emu.AppImage "${DOLPHIN_APP_IMAGE_URL}"

# Install Cemu
ARG CEMU_APP_IMAGE_URL=https://github.com/cemu-project/Cemu/releases/download/v2.0-61/Cemu-2.0-61-x86_64.AppImage
RUN \
    echo "**** Downloading CEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        wget -O cemu-emu.AppImage "${CEMU_APP_IMAGE_URL}"

# Pegasus still requires libssl1.1, but ubuntu switched to libssl3. Need to manually install it.
# TODO: Doing this could be a terrible idea (it does work)
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb --output-document=libssl1.1.deb && \
    dpkg -i libssl1.1.deb

# Install pegasus
# ARG PEGASUS_DOWNLOAD=https://github.com/mmatyas/pegasus-frontend/releases/download/weekly_2023w20/pegasus-frontend_0.16.51_amd64.deb
ARG PEGASUS_DOWNLOAD=https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-frontend_0.16.75_amd64.deb
RUN apt-get install -y --no-install-recommends \
    fontconfig \
    gstreamer1.0-alsa \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-good \
    gstreamer1.0-gl \
    libgstreamer1.0-dev \
    libsdl2-2.0-0 \
    libxcb-glx0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libzstd1 \
    policykit-1 \
    unzip && \
    wget $PEGASUS_DOWNLOAD --output-document=pegasus-frontend.deb && \
    dpkg -i pegasus-frontend.deb

# Move all the apps out of /tmp and to the /Applications folder
RUN \
    echo "**** Preparing Applications for symlinking ****" && \
        mkdir -p /Applications && \
        mv /tmp/*.AppImage /Applications && \
		chmod -v -R 777 /Applications/ && \
		chmod -v -R a+x /Applications/

# Cleanup
RUN apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy config files
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

# Copy Pegasus related files
COPY scripts/launchers/*.sh /bin/
COPY scripts/tools/*.sh /bin/
COPY configs /cfg

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
