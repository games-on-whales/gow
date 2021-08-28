FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro

# Taken from https://github.com/jessfraz/dockerfiles/blob/master/pulseaudio/
RUN apt-get update && apt-get install -y --no-install-recommends \
    alsa-utils \
    libasound2 \
    libasound2-plugins \
    pulseaudio \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /home/$UNAME
WORKDIR $HOME

COPY pulseaudio/configs/default.pa /etc/pulse/default.pa
COPY pulseaudio/configs/client.conf /etc/pulse/client.conf
COPY pulseaudio/configs/daemon.conf /etc/pulse/daemon.conf
COPY pulseaudio/scripts/startup.sh /startup.sh
# Common scripts
COPY --chmod=777 common/* /bin/

EXPOSE 4713

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
