FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro
# Pulling Sunshine v0.8.0
ARG SUNSHINE_SHA=ae04c4afbbc44e1b6e15fcb38e9afdd6473b5005
ENV SUNSHINE_SHA=${SUNSHINE_SHA}

######################################
FROM base AS sunshine-builder

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    # Packages needed to build sunshine
    build-essential fakeroot gcc-10 g++-10 cmake libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    git ca-certificates apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/loki-47-6F-64/sunshine.git && \
    cd sunshine && \
    # Fix the SHA commit
    git checkout $SUNSHINE_SHA && \
    # Just printing out git info so that I can double check on CI if the right version as been picked up
    git show && \
    # Recursively download submodules
    git submodule update --init --recursive && \
    # Normal compile
    mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=gcc-10 -DCMAKE_CXX_COMPILER=g++-10 -DCMAKE_BUILD_TYPE=Release -DSUNSHINE_EXECUTABLE_PATH=sunshine -DSUNSHINE_ASSETS_DIR=/etc/sunshine .. && \
    make -j ${nproc} && \
    # Generate the debian install package
    ./gen-deb

######################################
FROM base AS sunshine

# Get compiled sunshine
COPY --from=sunshine-builder /sunshine/build/package-deb/sunshine.deb /sunshine.deb

# Install using the official .deb package
# This will take care of installing the required dependencies
RUN apt-get update -y && \
    apt-get install -y -f /sunshine.deb \
    # Seems that libgbm1 is missing
    && apt-get install -y --no-install-recommends libgbm1 \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /home/$UNAME
# Set up the user
# Taken from https://github.com/TheBiggerGuy/docker-pulseaudio-example
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p ${HOME} && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R ${HOME}


WORKDIR $HOME
USER ${UNAME}

# Config files
COPY configs/sunshine.conf /cfg/sunshine.conf
COPY configs/apps.json /cfg/apps.json
COPY scripts/startup.sh /startup.sh

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 48010/udp 
EXPOSE 47998-48000/udp


CMD /bin/bash /startup.sh
