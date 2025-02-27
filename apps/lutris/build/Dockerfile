ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# The following list of packages is informed by these articles;
#   - https://github.com/lutris/docs/blob/master/InstallingDrivers.md
#   - https://github.com/lutris/docs/blob/master/WineDependencies.md
ARG REQUIRED_PACKAGES=" \
# The currently packaged version of Lutris in Ubuntu is no longer supported
#     lutris \
     cabextract \
     curl \
     fluid-soundfont-gs \
     gir1.2-gtk-3.0 \
     gir1.2-notify-0.7 \
     gir1.2-webkit2-4.1 \
     libasound2-plugins:i386 \
     libdbus-1-3:i386 \
     libfreetype6:i386 \
     libsdl2-2.0-0:i386 \
     libsqlite3-0:i386 \
     libvulkan1 \
     libvulkan1:i386 \
     mesa-utils \
     mesa-vulkan-drivers \
     mesa-vulkan-drivers:i386 \
     p7zip \
     python3-distro \
     python3-gi-cairo \
     python3-lxml \
     python3-magic \
     python3-pil \
     python3-requests \
     python3-setproctitle \
     python3-yaml \
     unzip \
     vulkan-tools \
     wine-stable \
     wine32 \
     wine64 \
     winetricks \
     x11-xserver-utils \
     zenity \
    "

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES

    # Manually installing the latest stable release per https://lutris.net/downloads
RUN wget -q 'https://github.com/lutris/lutris/releases/download/v0.5.18/lutris_0.5.18_all.deb' && \
    dpkg -i lutris_0.5.18_all.deb && \
    rm lutris_0.5.18_all.deb && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -pm 777 /var/lutris/ && \
    mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/lutris-system.yml /opt/gow/lutris-system.yml
COPY configs/lutris-lutris.conf /opt/gow/lutris-lutris.conf

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
