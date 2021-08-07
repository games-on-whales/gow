FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common sudo && \
    # \
    # Install retroarch \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y retroarch retroarch-assets libretro* \
    # Install xdpyinfo so that we can wait for X11 on startup
    x11-utils \
    && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Common scripts
COPY --chmod=777 common/* /bin/
# Set up the user
RUN setup-retro-user


WORKDIR $HOME
USER ${UNAME}

COPY retroarch/configs/retroarch.cfg /cfg/retroarch.cfg
COPY retroarch/scripts/startup.sh /startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh
