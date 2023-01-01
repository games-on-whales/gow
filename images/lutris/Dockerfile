ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Get the latest wine && winetricks
# The following is based on gloriouseggroll's advice on how to get out of wine dependency hell
RUN dpkg --add-architecture i386
RUN apt-get update -y && \
    apt-get install -y wget
RUN wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources"
RUN apt-get update -y && \
    apt-get install -y --install-recommends gnupg winehq-staging winetricks

# Install Lutris \
RUN apt-get install -y lutris

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

USER ${UNAME}

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
