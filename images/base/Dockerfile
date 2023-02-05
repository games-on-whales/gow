FROM ubuntu:22.04

# Configure default user and set env
# The users UID and GID will be set on container startup
ENV \
    PUID=1000 \
    PGID=1000 \
    UMASK=000 \
    UNAME="retro" \
    HOME="/home/retro" \
    TZ="Europe/London"
RUN \
    echo "**** Configure default user '${UNAME}' ****" \
        && useradd -m -d ${HOME} -s /bin/bash ${UNAME} \
    && \
    echo

# Install default required packages
ARG DEBIAN_FRONTEND=noninteractive
# TODO: If we need to download multi arch, then this will beed to be updated
ARG GOSU_VERSION=1.14
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install certificates ****" \
        && apt-get install -y --reinstall --no-install-recommends \
            ca-certificates \
    && \
    echo "**** Install base packages ****" \
        && apt-get install -y --no-install-recommends \
            fuse \
            libnss3 \
            wget \
    && \
    echo "**** Install gosu ****" \
        && wget --progress=dot:giga \
            -O /usr/bin/gosu \
            https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
        && chmod +x /usr/bin/gosu \
    && \
    echo "**** Verify gosu works ****" \
        && gosu nobody true && echo "Working!" \
    && \
    echo "**** Section cleanup ****" \
        && rm -rf \
            /var/lib/apt/lists/* \
    && \
    echo

# Import overlay
COPY overlay /

# Set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
