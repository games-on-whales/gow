ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    "

RUN apt-get update && \
    apt-get install -y xfce4

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
