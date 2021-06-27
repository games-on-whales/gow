FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME
ARG SUNSHINE_VERSION=v0.7.7
ENV SUNSHINE_VERSION=${SUNSHINE_VERSION}

# Installing Sunshine using the .deb package
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl ca-certificates && \
    curl -L -o /tmp/sunshine20-04.deb https://github.com/loki-47-6F-64/sunshine/releases/download/${SUNSHINE_VERSION}/sunshine20-04.deb && \
    apt-get install -y --no-install-recommends -f /tmp/sunshine20-04.deb && \
    # Cleanup
    apt-get remove -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Unfortunately this seems to not be enough since at runtime I get:
# sunshine: error while loading shared libraries: libXtst.so.6: cannot open shared object file: No such file or directory
# Sunshine dependencies, taken from  sunshine/gen-deb.in 
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    # Depends: libssl1.1, libavdevice58, libboost-thread1.67.0 | libboost-thread1.71.0, libboost-filesystem1.67.0 | libboost-filesystem1.71.0, libboost-log1.67.0 | libboost-log1.71.0, libpulse0, libopus0, libxcb-shm0, libxcb-xfixes0
    libssl1.1 libavdevice58 libboost-thread1.71.0 libboost-filesystem1.71.0 libboost-log1.71.0 libpulse0 libopus0 libxcb-shm0 libxcb-xfixes0 libxtst6 \
    # This is still not enough since then it complains about:
    # sunshine: error while loading shared libraries: libevdev.so.2: cannot open shared object file: No such file or directory
    libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    && rm -rf /var/lib/apt/lists/*

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
