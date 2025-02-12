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
    # Get PrismLauncher from makedeb \
    wget -qO - "https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub" | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | tee /etc/apt/sources.list.d/prebuilt-mpr.list && \
    apt update && \
    apt install -y prismlauncher && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* 

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
