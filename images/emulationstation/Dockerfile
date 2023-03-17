ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    wget p7zip-full \
    retroarch \
    libretro* \
    fuse \
"
RUN \
    echo "**** Install ESDE ****" \
        && wget -O /tmp/esde.deb https://gitlab.com/es-de/emulationstation-de/-/package_files/71412450/download \
        && apt install -y /tmp/esde.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent libusb-1.0-0 libglu1-mesa libaio1 libaio-dev && \
    # \
    # Install retroarch \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

#Install PCSX2
RUN apt-get update && \
    add-apt-repository -y ppa:pcsx2-team/pcsx2-daily && \
    apt-get install -y pcsx2-unstable && \

# Install RPCS3
RUN \
    echo "**** Install RPCS3 ****" \
        && mkdir /home/retro/Applications \
        && cd /home/retro/Applications \
        && wget -O rpcs3-emu.AppImage https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-6809d84a0029377eab059a51ce38f440e325be1c/rpcs3-v0.0.26-14564-6809d84a_linux64.AppImage \
        && chmod +x /home/retro/Applications/rpcs3-emu.AppImage


COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
