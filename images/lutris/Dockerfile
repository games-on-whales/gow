ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG REQUIRED_PACKAGES=" \
    libfreetype6 gnupg winehq-staging winetricks steam lutris epiphany-browser \
    libvulkan1 libvulkan1:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 \
"
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget software-properties-common && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources" && \
    echo "deb https://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" | tee /etc/apt/sources.list.d/lutris.list && \
    wget -qO- https://download.opensuse.org/repositories/home:/strycore/Debian_11/Release.key | tee /etc/apt/trusted.gpg.d/lutris.asc && \
    # \
    # Install steam (Steam is 32-bit only) \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
