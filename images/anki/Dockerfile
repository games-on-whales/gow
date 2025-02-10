ARG BASE_APP_IMAGE
# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG ANKI_APP_VERSION="24.11"

RUN apt-get update &&\
    apt-get install -y libxcb-xinerama0 libxcb-cursor0 libnss3 zstd xdg-utils

RUN wget https://github.com/ankitects/anki/releases/download/${ANKI_APP_VERSION}/anki-${ANKI_APP_VERSION}-linux-qt6.tar.zst &&\
    tar xaf anki-${ANKI_APP_VERSION}-linux-qt6.tar.zst &&\
    cd anki-${ANKI_APP_VERSION}-linux-qt6 &&\
    ./install.sh

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE