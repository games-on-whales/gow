ARG BUILD_OWNER
ARG BUILD_TAG
FROM ghcr.io/${BUILD_OWNER}/base:${BUILD_TAG} AS sunshine

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends udev \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
