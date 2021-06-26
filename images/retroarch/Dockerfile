FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Install retroarch
    software-properties-common && \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y retroarch libretro-* && \
    # Cleanup
    apt-get remove -y software-properties-common \
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

COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY scripts/startup.sh /startup.sh

CMD /bin/bash /startup.sh