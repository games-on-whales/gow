# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Install required packages for VR, Steam, and ALVR
ARG REQUIRED_PACKAGES=" \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libx11-dev \
    libxrandr-dev \
    libasound2-dev \
    libudev-dev \
    libdbus-1-dev \
    steam \
    firefox \
    software-properties-common \
    dbus-daemon \
    dbus-system-bus-common \
    dbus-session-bus-common \
    network-manager \
    bluez \
    ibus \
    pkexec \
    xz-utils \
    zenity \
    file \
    xdg-user-dirs \
    xdg-utils \
    pciutils \
    lsb-release \
    mesa-utils \
    libfontconfig1:i386 \
    libfontconfig1:amd64 \
    libfreetype6 \
    libfreetype6:i386 \
    "

# Install Steam and dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository multiverse && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # Fix steam updater UI font file \
    ln -s /usr/share/fonts/truetype/dejavu /usr/share/fonts/truetype/ttf-dejavu && \
    # skip annoying debian dialog \
    rm /usr/bin/zenity && ln -s /usr/bin/true /usr/bin/zenity && \
    # refresh system font cache \
    fc-cache -f -v && \
    # fix NetworkManager not picking up devices \
    touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Download and install ALVR Server
RUN mkdir -p /opt/alvr && \
    cd /opt/alvr && \
    curl -L -o alvr.tar.gz $(curl -s https://api.github.com/repos/alvr-org/ALVR/releases/latest | grep "browser_download_url.*alvr_launcher_linux.tar.gz" | cut -d '"' -f 4) && \
    tar -xzf alvr.tar.gz && \
    rm alvr.tar.gz && \
    chmod +x alvr_launcher && \
    ln -s /opt/alvr/alvr_launcher /usr/local/bin/alvr

# Install OpenXR runtime (for better VR integration)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libopenxr-loader1 libopenxr1-monado && \
    rm -rf /var/lib/apt/lists/*

# Create ALVR config directory
RUN mkdir -p /home/retro/.local/share/alvr && \
    chown -R retro:retro /home/retro/.local

# Copy configuration files
COPY configs/alvr_config.json /opt/alvr/alvr_config.json
COPY configs/openxr_runtime.json /home/retro/.config/openxr/1/active_runtime.json

# Copy startup scripts
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/start-alvr.sh /usr/local/bin/start-alvr
COPY --chmod=777 scripts/start-steamvr.sh /usr/local/bin/start-steamvr

# Set environment for VR
ENV XDG_RUNTIME_DIR=/tmp/.X11-unix
ENV STEAM_VR=1
ENV XR_RUNTIME_JSON=/home/retro/.config/openxr/1/active_runtime.json

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
