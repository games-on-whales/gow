FROM ubuntu:21.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro

# Pulling SunshineStream v0.14.0
ARG SUNSHINE_SHA=70ae7a2fa9b33173eb949c86ec42a96e7b9e8c25
ENV SUNSHINE_SHA=${SUNSHINE_SHA}
ARG BUILD_TYPE=RELEASE
ENV BUILD_TYPE=${BUILD_TYPE}

######################################
FROM base AS sunshine-builder

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    # Packages needed to build sunshine
    build-essential fakeroot gcc-10 g++-10 cmake libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    git ca-certificates apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recurse-submodule https://github.com/SunshineStream/Sunshine sunshine && \
    cd sunshine && \
    # Fix the SHA commit
    git checkout -qf $SUNSHINE_SHA && \
    # Just printing out git info so that I can double check on CI if the right version as been picked up
    git show && \
    # Normal compile
    mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=gcc-10 -DCMAKE_CXX_COMPILER=g++-10 -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DSUNSHINE_EXECUTABLE_PATH=sunshine -DSUNSHINE_ASSETS_DIR=/etc/sunshine .. && \
    make -j${nproc} && \
    # Generate .DEB installation file
    cpack -G DEB

######################################
FROM base AS sunshine

# Get compiled sunshine
COPY --from=sunshine-builder /sunshine/build/cpack_artifacts/Sunshine.deb /sunshine.deb

# Install using the official .deb package
# This will take care of installing the required dependencies
RUN apt-get update -y && \
    apt-get install -y -f /sunshine.deb \
    && apt-get install -y --no-install-recommends \
    # Seems that libgbm1 and libgl is missing
    libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri \
    # Intel GPU drivers
    i965-va-driver-shaders \
    intel-media-va-driver-non-free \
    libdrm-intel1 \
    libva-drm2 libva-x11-2 va-driver-all \
    # Install xdpyinfo so that we can wait for X11 on startup
    x11-utils \
    # libavahi for LAN discovery
    libavahi-client3 \
    # sudo isn't installed by default
    sudo \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /home/$UNAME

# Common scripts
COPY --chmod=777 common/* /bin/
# Set up the user
RUN setup-retro-user

# Utils for debugging
# RUN apt-get update -y && \
#     apt-get install -y --no-install-recommends gdb vainfo ffmpeg \
#     && apt-get remove -y software-properties-common \
#     && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
USER ${UNAME}

# Config files
COPY sunshine/configs/sunshine.conf /cfg/sunshine.conf
COPY sunshine/configs/apps.json /cfg/apps.json
COPY sunshine/scripts/startup.sh /startup.sh

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 48010/udp 
EXPOSE 47998-48000/udp

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
