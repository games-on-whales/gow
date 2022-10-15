ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends udev \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
