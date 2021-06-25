FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    # Sunshine dependencies, taken from  sunshine/gen-deb.in 
    # Depends: libssl1.1, libavdevice58, libboost-thread1.67.0 | libboost-thread1.71.0, libboost-filesystem1.67.0 | libboost-filesystem1.71.0, libboost-log1.67.0 | libboost-log1.71.0, libpulse0, libopus0, libxcb-shm0, libxcb-xfixes0
    libssl1.1 libavdevice58 libboost-thread1.71.0 libboost-filesystem1.71.0 libboost-log1.71.0 libpulse0 libopus0 libxcb-shm0 libxcb-xfixes0 \
    && rm -rf /var/lib/apt/lists/*

######################################
FROM base AS sunshine-builder

# Pulling Sunshine v0.7 with fixes for https://github.com/loki-47-6F-64/sunshine/issues/97
ARG SUNSHINE_SHA=23b09e3d416cc57b812544c097682060be5b3dd3
ENV SUNSHINE_SHA=${SUNSHINE_SHA}

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    git ca-certificates apt-transport-https build-essential cmake \
    # Packages needed to build sunshine
    libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
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
    cmake .. && \
    make -j ${nproc}

######################################
FROM base AS sunshine-retroarch

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Install retroarch
    software-properties-common && \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y retroarch libretro-* && \
    # Cleanup
    apt-get remove -y software-properties-common \
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
    chown ${UID}:${GID} -R ${HOME} && \
    gpasswd -a ${UNAME} audio && \
    # Attempt to fix permissions
    usermod -a -G systemd-resolve,audio,video,render ${UNAME}


WORKDIR $HOME
USER ${UNAME}

# Get compiled sunshine
COPY --from=sunshine-builder /sunshine/build/ /sunshine/
COPY --from=sunshine-builder /sunshine/assets/ /sunshine/assets


# Config files
COPY configs/sunshine.conf /cfg/sunshine.conf
COPY configs/apps.json /cfg/apps.json
COPY scripts/startup-sunshine.sh /startup.sh
COPY configs/retroarch.cfg /cfg/retroarch.cfg

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 48010/udp 
EXPOSE 47998-48000/udp


CMD /bin/bash /startup.sh
