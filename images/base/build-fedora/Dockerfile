# syntax=docker/dockerfile:1.4
FROM quay.io/fedora/fedora:44

# Configure default user and set env
# The users UID and GID will be set on container startup
ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    HOME="/home/retro" \
    TZ="Europe/London"

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

# Create the user at build time, so the container can also start directly as
# it (`--user retro`, like `--user pulse`), skipping the root-only init and gosu.
# Starting as root is unchanged: 10-setup_user.sh moves it to PUID/PGID.
# dnf above already created $HOME (as root), and useradd -m won't take it over
RUN groupadd -g "${PGID}" "${UNAME}" && \
    useradd -m -d "${HOME}" -u "${PUID}" -g "${PGID}" -s /bin/bash "${UNAME}" && \
    chown -R "${PUID}:${PGID}" "${HOME}"

# Import overlay
COPY overlay /

# Set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
