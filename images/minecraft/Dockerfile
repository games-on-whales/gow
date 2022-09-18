FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common sudo && \
    # Minecraft dependencies \
    apt-get install -y x11-utils apt-utils dbus-x11 default-jre libasound2 \
      libatk-bridge2.0-0 libatk1.0-0 libcairo2 libgbm1 libgdk-pixbuf2.0-0 libgtk-3-0 \
      libpango1.0-0 libpangocairo-1.0-0 libxcursor1 libxdamage1 xdg-utils libxss1 wget \
      libsecret-1-0 gnome-keyring orca curl && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/minecraft.deb https://launcher.mojang.com/download/Minecraft.deb && \
    dpkg -i /tmp/minecraft.deb && \
    rm /tmp/minecraft.deb

# Common scripts
COPY --chmod=777 common/* /bin/

# Set up the user
RUN setup-retro-user

WORKDIR $HOME
USER ${UNAME}

COPY minecraft/scripts/startup.sh /startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
