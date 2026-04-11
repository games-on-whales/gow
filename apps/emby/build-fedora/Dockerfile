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
    tar \
    curl \
    jq \
    findutils

URL=$(curl -fsSL https://api.github.com/repos/MediaBrowser/emby-theater-electron/releases/latest \
    | jq -r '.assets[] | select(.name | test("linux.*x64.*\\.tar\\.gz$")) | .browser_download_url' \
    | head -n1)

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve Emby Theater tarball URL" >&2
    exit 1
fi

mkdir -p /opt/emby-theater
curl -fsSL -o /tmp/emby-theater.tar.gz "$URL"
tar -xzf /tmp/emby-theater.tar.gz -C /opt/emby-theater --strip-components=1
rm -f /tmp/emby-theater.tar.gz

BIN=$(find /opt/emby-theater -maxdepth 2 -type f \( -name 'emby-theater' -o -name 'embytheater' \) | head -n1)
if [ -z "$BIN" ]; then
    echo "Could not locate emby-theater binary inside tarball" >&2
    exit 1
fi
ln -sf "$BIN" /usr/local/bin/emby-theater
chmod +x "$BIN"

dnf clean all
_INSTALL_EMBY

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
