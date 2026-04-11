# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_EMBY
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

URL=$(curl -fsSL https://api.github.com/repos/MediaBrowser/emby-theater-electron/releases/latest \
    | jq -r '.assets[] | select(.name | test("^emby-theater-rpm_.*_x86_64\\.rpm$")) | .browser_download_url' \
    | head -n1)

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve Emby Theater .rpm download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/emby-theater.rpm "$URL"
dnf install -y /tmp/emby-theater.rpm
rm -f /tmp/emby-theater.rpm

dnf clean all
_INSTALL_EMBY

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
