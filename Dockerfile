FROM ubuntu:20.04 AS base

ARG DEBIAN_FRONTEND=noninteractive 
ARG TZ="Europe/London"

RUN apt-get update -y && \
    apt-get install -y \
    libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev

######################################
FROM base AS sunshine-builder

RUN apt-get install -y git build-essential cmake

RUN git clone https://github.com/loki-47-6F-64/sunshine.git --recurse-submodules && \
    cd sunshine && mkdir build && cd build && \
    cmake .. && \
    make -j ${nproc}

######################################
FROM base AS retroarch

RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y xvfb retroarch pulseaudio-utils

# ENV UNAME retro

# Set up the user
# Taken from https://github.com/TheBiggerGuy/docker-pulseaudio-example
# RUN export UNAME=$UNAME UID=1000 GID=1000 && \
#     mkdir -p "/home/${UNAME}" && \
#     echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
#     echo "${UNAME}:x:${UID}:" >> /etc/group && \
#     mkdir -p /etc/sudoers.d && \
#     echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
#     chmod 0440 /etc/sudoers.d/${UNAME} && \
#     chown ${UID}:${GID} -R /home/${UNAME} && \
#     gpasswd -a ${UNAME} audio && \
#     # Attempt to fix /dev/input permissions
#     usermod -a -G systemd-resolve ${UNAME} && \
#     usermod -a -G sudo ${UNAME}


# USER $UNAME

COPY --from=sunshine-builder /sunshine/build/ /sunshine/
COPY --from=sunshine-builder /sunshine/assets/ /sunshine/assets
ADD sunshine/sunshine.conf /sunshine/sunshine.conf
ADD sunshine/apps.json /sunshine/apps.json
COPY sunshine/pulse-client.conf /etc/pulse/client.conf
COPY startup.sh /startup.sh

CMD /bin/bash /startup.sh
