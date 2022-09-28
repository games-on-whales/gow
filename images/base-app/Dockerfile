ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# TODO: should we include any drivers or anything here? The GL stuff that the
# sunshine container has, or the intel drivers, etc?  AMD drivers?
ARG REQUIRED_PACKAGES="\
    x11-utils \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh
