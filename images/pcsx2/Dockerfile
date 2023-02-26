ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libvulkan1 \
    software-properties-common \
    "

RUN apt-get update && \
    apt-get install $REQUIRED_PACKAGES -y

RUN add-apt-repository -y ppa:pcsx2-team/pcsx2-daily 

RUN apt-get update && \
    apt-get install -y pcsx2-unstable

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
