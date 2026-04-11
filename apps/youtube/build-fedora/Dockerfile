# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_FREETUBE
set -e

dnf install -y \
    nss \
    libXScrnSaver \
    alsa-lib \
    mesa-libgbm \
    gtk3 \
    libsecret \
    libnotify \
    at-spi2-core \
    libdrm \
    libxkbcommon \
    libXcomposite \
    libXdamage \
    libXrandr \
    libxshmfence \
    cups-libs \
    xdg-utils \
    curl \
    jq

URL=$(curl -fsSL https://api.github.com/repos/FreeTubeApp/FreeTube/releases/latest \
    | jq -r '.assets[] | select(.name | test("x86_64\\.rpm$")) | .browser_download_url' \
    | head -n1)

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve FreeTube .rpm download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/freetube.rpm "$URL"
dnf install -y /tmp/freetube.rpm
rm -f /tmp/freetube.rpm

dnf clean all
_INSTALL_FREETUBE

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
