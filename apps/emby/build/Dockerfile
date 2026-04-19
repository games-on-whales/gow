# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libnss3 \
    libxss1 \
    libasound2t64 \
    libgbm1 \
    libgtk-3-0 \
    libsecret-1-0 \
    libnotify4 \
    libatspi2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libx11-xcb1 \
    libxshmfence1 \
    libcups2 \
    xdg-utils \
    "

RUN <<_INSTALL_EMBY
set -e
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES ca-certificates curl jq

URL=$(curl -fsSL https://api.github.com/repos/MediaBrowser/emby-theater-electron/releases/latest \
    | jq -r '.assets[] | select(.name | test("^emby-theater-deb_.*_amd64\\.deb$")) | .browser_download_url' \
    | head -n1)

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve Emby Theater .deb download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/emby-theater.deb "$URL"
apt-get install -y /tmp/emby-theater.deb
rm -f /tmp/emby-theater.deb

apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_EMBY

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
