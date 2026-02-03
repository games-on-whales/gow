# syntax=docker/dockerfile:1.4
FROM fedora:43

# Configure default user and set env
# The users UID and GID will be set on container startup
ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    HOME="/home/retro" \
    TZ="Europe/London" \
    DEBIAN_FRONTEND=noninteractive \
    NEEDRESTART_SUSPEND=1

ARG TARGETARCH TARGETVARIANT

# Install default required packages
ARG GOSU_VERSION=1.14

RUN <<_INSTALL_PACKAGES
#!/bin/bash
set -e

echo "**** Install base packages ****"
dnf -y install \
        ca-certificates \
        fuse \
        wget \
        curl \
        jq

echo "**** Install gosu ****"
wget --progress=dot:giga \
    -O /usr/bin/gosu \
    "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}${TARGETVARIANT}"
chmod +x /usr/bin/gosu

echo "**** Verify gosu works ****"
gosu nobody true && echo "Working!"

echo "**** Section cleanup ****"
dnf clean all

echo
_INSTALL_PACKAGES

# Import overlay
COPY overlay /

# Set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
