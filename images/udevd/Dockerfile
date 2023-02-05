ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Configure container to run process as root user
ENV \
    UNAME="root" \
    HOME="/root"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends udev \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
