ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES="libopenal1"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        $REQUIRED_PACKAGES \
        && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/run-benchmark.sh /opt/gow/run-benchmark.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
