ARG BUILD_OWNER
ARG BUILD_TAG
FROM ghcr.io/${BUILD_OWNER}/base-app:${BUILD_TAG}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    retroarch \
    retroarch-assets \
    libretro* \
"

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
    # \
    # Install retroarch \
    add-apt-repository ppa:libretro/stable && \
    apt-get install -y $REQUIRED_PACKAGES && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
USER ${UNAME}

COPY configs/retroarch.cfg /cfg/retroarch.cfg
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
