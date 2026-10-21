# syntax=docker/dockerfile:1.4
FROM docker.io/library/ubuntu:25.04

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
set -e
echo "**** Update apt database ****"
apt-get update

echo "**** Install certificates ****"
apt-get install -y --reinstall --no-install-recommends \
    ca-certificates

echo "**** Install base packages ****"
apt-get install -y --no-install-recommends \
    fuse \
    libnss3 \
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
rm -rf \
    /var/lib/apt/lists/*

echo
_INSTALL_PACKAGES

# Create the user at build time, so the container can also start directly as
# it (`--user retro`, like `--user pulse`), skipping the root-only init and gosu.
# Starting as root is unchanged: 10-setup_user.sh moves it to PUID/PGID.
RUN <<_CREATE_USER
set -e
# Ubuntu ships an 'ubuntu' user with UID 1000
if id -u ubuntu >/dev/null 2>&1; then
    userdel -r ubuntu
fi
groupadd -g "${PGID}" "${UNAME}"
useradd -m -d "${HOME}" -u "${PUID}" -g "${PGID}" -s /bin/bash "${UNAME}"
_CREATE_USER

# Import overlay
COPY overlay /

# Set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
