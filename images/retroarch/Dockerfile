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
    apt-get install -y retroarch libretro-* \
    # Install xdpyinfo so that we can wait for X11 on startup
    x11-utils \
    && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    # Create the user and a home dir for them \
    groupadd -f -g "${GID}" "${UNAME}" && \
    useradd -mk $(mktemp -d) -u "${UID}" -g "${GID}" "${UNAME}" && \
    # \
    # Set up sudoers \
    mkdir -p /etc/sudoers.d && \
    # $UNAME should be able to add groups without a password \
    echo "${UNAME} ALL=(root) NOPASSWD: $(which groupadd)" >> /etc/sudoers.d/${UNAME} && \
    # $UNAME should be able to add itself to groups without a password \
    echo "${UNAME} ALL=(root) NOPASSWD: $(which usermod) -G * ${UNAME}" >> /etc/sudoers.d/${UNAME} && \
    # $UNAME should be able to run any commands as itself without a password \
    # this makes it easy to reload group memberships \
    echo "${UNAME} ALL=($UNAME) NOPASSWD: ALL" >> /etc/sudoers.d/${UNAME} && \
    chmod 0444 /etc/sudoers.d/${UNAME}


WORKDIR $HOME
USER ${UNAME}

COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY scripts/ensure-groups.sh /ensure-groups.sh
COPY scripts/startup.sh /startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh
