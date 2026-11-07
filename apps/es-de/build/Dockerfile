ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

#GitHub REST query versioning
ARG GITHUB_REST_VERSION=2022-11-28

# Downloading ES-DE AppImage.
# Capture, validate, then download; otherwise a transient GitLab blip lets
# `xargs wget -O esde.AppImage` run with no URL and produce a broken file.
RUN <<_INSTALL_ESDE
#!/bin/bash
set -e
echo "**** Downloading ESDE AppImage ****"
mkdir -p /tmp
cd /tmp
release_json=$(curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 --retry-max-time 60 \
    https://gitlab.com/api/v4/projects/18817634/releases)
download_url=$(echo "$release_json" | jq -r '.[0].assets.links[]|select(.name=="ES-DE_x64.AppImage").direct_asset_url' | head -n 1)
if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
    echo "es-de: no ES-DE_x64.AppImage asset in latest release" >&2
    exit 1
fi
wget --tries=5 --waitretry=2 --timeout=30 -O /Applications/esde.AppImage "$download_url"
chmod -v -R 777 /Applications/esde.AppImage
chmod -v -R a+x /Applications/esde.AppImage
_INSTALL_ESDE

RUN \
    echo "**** Preparing /media for EmulationStation ****" && \
        mkdir -pm777 /media
		
RUN \
    echo "**** Preparing /bioses for symlinking ****" && \
        mkdir -pm755 /bioses

RUN \
    echo "**** Preparing /ROMs for symlinking ****" && \
        mkdir -pm755 /ROMs

COPY configs/ /cfg/
COPY --chmod=777 scripts/startup.sh /etc/cont-init.d/setup-de.sh
COPY --chmod=777 scripts/startup-es.sh /opt/gow/startup-app.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
