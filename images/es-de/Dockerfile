ARG BASE_EMU_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_EMU_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

#GitHub REST query versioning
ARG GITHUB_REST_VERSION=2022-11-28

# Downloading ES-DE AppImage
RUN \
    echo "**** Downloading ESDE AppImage ****" && \
        mkdir -p /tmp && \
        cd /tmp && \
        curl https://gitlab.com/api/v4/projects/18817634/releases | \
        jq '.[0].assets.links[]|select(.name|endswith(".AppImage"))|select(.name|contains("SteamDeck")|not).direct_asset_url' | \
        xargs wget -O /Applications/esde.AppImage && \
        chmod -v -R 777 /Applications/esde.AppImage && \
    	chmod -v -R a+x /Applications/esde.AppImage

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
