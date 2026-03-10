ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

######################################
# Same as Steam, here we build a patched bubblewrap
# that works with CAP_SYS_ADMIN in containers.
# bwrap detects explicit capabilities and aborts; this patch removes that check.
FROM ubuntu:25.04 AS bwrap-builder

ENV DEBIAN_FRONTEND=non-interactive
WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git meson ca-certificates dpkg-dev && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    ./ci/builddeps.sh && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson _builddir && \
    meson compile -C _builddir

######################################

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# Hardcoded the version to prevent image builder using cached old packages when newer version comes out
ARG LUTRIS_VERSION=0.5.22

ARG DEBIAN_FRONTEND=noninteractive

# The following list of packages was informed by these articles;
#   - https://github.com/lutris/docs/blob/master/InstallingDrivers.md
#   - https://github.com/lutris/docs/blob/master/WineDependencies.md
#
# Also added libegl1:i386 which is required for winegstreamer.so (32-bit)
# to load inside the pressure-vessel sniper runtime.
# Without it, Wine's quartz.dll crashes during DirectShow initialization,
# causing Themida-protected games to raise SIGTRAP via direct Linux syscall.
ARG REQUIRED_PACKAGES=" \
     cabextract \
     curl \
     fluid-soundfont-gs \
     gir1.2-gtk-3.0 \
     gir1.2-notify-0.7 \
     gir1.2-webkit2-4.1 \
     libgdk-pixbuf2* \
     librsvg2* \
     libasound2-plugins:i386 \
     libdbus-1-3:i386 \
     libfreetype6:i386 \
     libgl1:i386 \
     libegl1:i386 \
     libsdl2-2.0-0:i386 \
     libsqlite3-0:i386 \
     libvulkan1 \
     libvulkan1:i386 \
     mesa-utils \
     mesa-vulkan-drivers \
     mesa-vulkan-drivers:i386 \
     p7zip \
     python3-dbus \
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

RUN echo 3$LUTRIS_VERSION && \
    curl -fsSL -o /tmp/lutris.deb \
        "https://github.com/lutris/lutris/releases/download/v${LUTRIS_VERSION}/lutris_${LUTRIS_VERSION}_all.deb" && \
    dpkg -i /tmp/lutris.deb && \
    rm -f /tmp/lutris.deb && \
    rm -rf /var/lib/apt/lists/*

# Replace system bwrap with patched version that works with CAP_SYS_ADMIN
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

RUN mkdir -pm 777 /var/lutris/ && \
    mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/lutris-system.yml /opt/gow/lutris-system.yml
COPY configs/lutris-lutris.conf /opt/gow/lutris-lutris.conf

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
