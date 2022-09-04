######################################
FROM ubuntu:22.04 AS sunshine-builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    # Packages needed to build sunshine
    build-essential fakeroot gcc-10 g++-10 cmake \
    libssl-dev libavdevice-dev libboost-thread-dev \
    libboost-filesystem-dev libboost-log-dev libpulse-dev \
    libopus-dev libxtst-dev libx11-dev libxrandr-dev \
    libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev binutils git ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Pulling Sunshine v0.14.0
ARG SUNSHINE_SHA=fbe8a37e9132c47e43fe31bfd8f35c67dc77ce77
ARG BUILD_TYPE=Release

ENV \
    SUNSHINE_SHA=${SUNSHINE_SHA} \
    BUILD_TYPE=${BUILD_TYPE}

RUN git clone --recurse-submodule https://github.com/Logical-sh/Sunshine sunshine && \
    cd sunshine && \
    # Fix the SHA commit
    git checkout -qf $SUNSHINE_SHA && \
    # Just printing out git info so that I can double check on CI if the right version as been picked up
    git show && \
    # Normal compile
    mkdir build && cd build && \
    cmake \
        -DCMAKE_C_COMPILER=gcc-10 \
        -DCMAKE_CXX_COMPILER=g++-10 \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DSUNSHINE_EXECUTABLE_PATH=sunshine \
        -DSUNSHINE_ASSETS_DIR=/etc/sunshine .. && \
    make -j${nproc} && \
    # Generate the debian install package
    cpack -G DEB

######################################
FROM ghcr.io/zb140/gow-base-x11:refactor AS sunshine

ARG REQUIRED_PACKAGES="\
    libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri \
    i965-va-driver-shaders \
    intel-media-va-driver-non-free \
    libdrm-intel1 \
    libva-drm2 libva-x11-2 va-driver-all \
    libavahi-client3 \
    "

# Install using the official .deb package
# This will take care of installing the required dependencies
RUN \
  --mount=type=bind,from=sunshine-builder,source=/sunshine/build/cpack_artifacts/Sunshine.deb,target=/sunshine.deb \
    apt-get update -y && \
    apt-get install -y -f /sunshine.deb && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Utils for debugging
# RUN apt-get update -y && \
#     apt-get install -y --no-install-recommends gdb vainfo ffmpeg \
#     && apt-get remove -y software-properties-common \
#     && rm -rf /var/lib/apt/lists/*

USER ${UNAME}

# Config files
COPY configs/sunshine.conf /cfg/sunshine.conf
COPY configs/apps.json /cfg/apps.json

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-x11.sh

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp 48010 48010/udp 47998-48000/udp

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
