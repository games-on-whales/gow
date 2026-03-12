ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# install all needed java runtimes.
ARG REQUIRED_PACKAGES=" \
    openjdk-21-jre \
    openjdk-17-jre \
    openjdk-8-jre \
    lsb-release \
    wget \
    gnupg2 \
    "

RUN apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # Get PrismLauncher from updated community source (https://prismlauncher.org/download/linux/) \
    wget https://prism-launcher-for-debian.github.io/repo/prismlauncher.gpg -O /usr/share/keyrings/prismlauncher-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/prismlauncher-archive-keyring.gpg] https://prism-launcher-for-debian.github.io/repo $(. /etc/os-release; echo "${UBUNTU_CODENAME:-${DEBIAN_CODENAME:-${VERSION_CODENAME}}}") main" | tee /etc/apt/sources.list.d/prismlauncher.list && \
    apt update && \
    apt install -y prismlauncher && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* 

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
