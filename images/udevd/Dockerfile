ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends udev \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ENV UDEVD_QUIET=false

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
