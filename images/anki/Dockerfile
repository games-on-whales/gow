ARG BASE_APP_IMAGE
# hadolint ignore=DL3006
FROM ghcr.io/games-on-whales/firefox:edge

ARG DEBIAN_FRONTEND=noninteractive

ARG ANKI_APP_VERSION="24.11"

RUN <<_ANKI_INSTALL

    apt-get update
    apt-get install -y --no-install-recommends libxcb-xinerama0 libxcb-cursor0 libnss3 zstd xdg-utils ufw dnsutils
    wget https://apps.ankiweb.net/downloads/archive/anki-${ANKI_APP_VERSION}-linux-qt6.tar.zst
    tar xaf anki-${ANKI_APP_VERSION}-linux-qt6.tar.zst
    cd anki-${ANKI_APP_VERSION}-linux-qt6
    ./install.sh
    apt-get autoremove -y --purge

_ANKI_INSTALL

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY overlay /

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE