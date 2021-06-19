FROM ubuntu:20.04 AS base

ARG DEBIAN_FRONTEND=noninteractive 
ARG TZ="Europe/London"

RUN apt-get update -y && \
    apt-get install -y \
    libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev

# Pulling Sunshine v0.7 with fixes for https://github.com/loki-47-6F-64/sunshine/issues/97
ARG SUNSHINE_SHA=23b09e3d416cc57b812544c097682060be5b3dd3
ENV SUNSHINE_SHA=${SUNSHINE_SHA}

######################################
FROM base AS sunshine-builder

RUN apt-get install -y git build-essential cmake

RUN git clone https://github.com/loki-47-6F-64/sunshine.git && \
    cd sunshine && \
    # Fix the SHA commit
    git checkout $SUNSHINE_SHA && \
    # Just printing out git info so that I can double check on CI if the right version as been picked up
    git show && \
    # Recursively download submodules
    git submodule update --init --recursive && \
    # Hack: commenting out all create_symlink to avoid issues when running (it's only used for debug purpose)
    # Here's the error I was getting:
    #   terminate called after throwing an instance of 'std::filesystem::__cxx11::filesystem_error'
    #   what():  filesystem error: cannot create symlink: Permission denied [/dev/input/event6] [sunshine_mouse]
    awk '/std::filesystem::create_symlink/ {$0="//"$0}1' sunshine/platform/linux/input.cpp > /tmp/sunshine_input.cpp && mv /tmp/sunshine_input.cpp sunshine/platform/linux/input.cpp && \
    # Normal compile
    mkdir build && cd build && \
    cmake .. && \
    make -j ${nproc}

######################################
FROM base as pulseaudio

# Taken from https://github.com/jessfraz/dockerfiles/blob/master/pulseaudio/
RUN apt-get install -y \
    alsa-utils \
    libasound2 \
    libasound2-plugins \
    pulseaudio \
    pulseaudio-utils \
    --no-install-recommends

COPY configs/pulseaudio/default.pa /etc/pulse/default.pa
COPY configs/pulseaudio/client.conf /etc/pulse/client.conf
COPY configs/pulseaudio/daemon.conf /etc/pulse/daemon.conf

######################################
FROM pulseaudio AS retroarch

RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y xvfb retroarch libretro-* && \
    # Cleanup
    apt-get remove -y software-properties-common

# Get compiled sunshine
COPY --from=sunshine-builder /sunshine/build/ /sunshine/
COPY --from=sunshine-builder /sunshine/assets/ /sunshine/assets

# Config files
COPY configs/sunshine.conf /sunshine/sunshine.conf
COPY configs/apps.json /sunshine/apps.json
COPY startup.sh /startup.sh
COPY configs/retroarch.cfg /retroarch.cfg

ENV UNAME retro

# Set up the user
# Taken from https://github.com/TheBiggerGuy/docker-pulseaudio-example
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    chown ${UID}:${GID} -R /sunshine/ && \
    gpasswd -a ${UNAME} audio && \
    # Attempt to fix permissions
    usermod -a -G systemd-resolve,audio,pulse,pulse-access ${UNAME}


USER root
WORKDIR /sunshine/

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 48010/udp 
EXPOSE 47998-48000/udp

CMD /bin/bash /startup.sh
