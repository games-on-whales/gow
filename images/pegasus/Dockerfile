ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG PEGASUS_DOWNLOAD=https://github.com/mmatyas/pegasus-frontend/releases/download/weekly_2023w20/pegasus-frontend_0.16.51_amd64.deb

# Install prereqs
RUN \
    echo "**** Install Prereqs (Mesa/Vulkan/Fuse/QT/Misc) ****" && \
		apt-get update && \
		apt-get install -y software-properties-common gpg-agent wget p7zip-full libvulkan1 mesa-vulkan-drivers libglu1-mesa-dev qtbase5-dev qt5-qmake ffmpeg x11-xserver-utils libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0

# Install retroarch
RUN \
    echo "**** Install Retroarch ****" && \
        apt-get update && \
        apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
    # Install retroarch \
        add-apt-repository ppa:libretro/stable && \
        apt-get install -y --no-install-recommends \
          retroarch \
          wget \
          p7zip-full \
          libretro-core-info \
          libretro-frontend \
          libusb-1.0-0 \
          libglu1-mesa \
          libaio1 \
          libaio-dev

# Pegasus requires libssl1.1, but ubuntu switched to libssl3. Need to manually install it.
# TODO: Doing this could be a terrible idea
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb --output-document=libssl1.1.deb && \
    dpkg -i libssl1.1.deb

# Install pegasus
RUN apt-get install -y --no-install-recommends libgstreamer1.0-dev \
    fontconfig \
    gstreamer1.0-alsa \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-good \
    gstreamer1.0-gl \
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
    policykit-1 && \
    wget $PEGASUS_DOWNLOAD --output-document=pegasus-frontend.deb && \
    dpkg -i pegasus-frontend.deb

# Downloading PCSX2 AppImage
RUN \
    echo "**** Downloading PCSX2 AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O pcsx2-emu-Qt.AppImage https://github.com/PCSX2/pcsx2/releases/download/v1.7.5181/pcsx2-v1.7.5181-linux-appimage-x64-Qt.AppImage

# Downloading XEMU AppImage
RUN \
    echo "**** Downloading XEMU AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
		wget -O xemu-emu.AppImage https://github.com/xemu-project/xemu/releases/download/v0.7.92/xemu-v0.7.92-x86_64.AppImage

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
        wget -O yuzu-emu.AppImage https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1460/yuzu-mainline-20230605-069d7e6be.AppImage

# Install Dolphin-emu \
RUN \
    echo "**** Installing Dolphin Emulator ****" && \
        add-apt-repository universe && \
        apt-get update && \
        apt-get install -y --no-install-recommends dolphin-emu

RUN \
    echo "**** Preparing /Applications for symlinking ****" && \
        mkdir -p /Applications && \
        mv /tmp/*.AppImage /Applications && \
		chmod -v -R 777 /Applications/ && \
		chmod -v -R a+x /Applications/

# Cleanup
RUN apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy config files
COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

# Copy Pegasus related files
COPY scripts/launchers/*.sh /bin/
COPY scripts/tools/*.sh /bin/
COPY configs/images/* /cfg/app/images/
COPY configs/metadata.pegasus.txt /cfg/app/metadata.pegasus.txt

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

# ARG IMAGE_SOURCE
# LABEL org.opencontainers.image.source $IMAGE_SOURCE
