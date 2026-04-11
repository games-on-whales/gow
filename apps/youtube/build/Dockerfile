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

RUN <<_INSTALL_FREETUBE
set -e
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES ca-certificates curl jq

URL=$(curl -fsSL https://api.github.com/repos/FreeTubeApp/FreeTube/releases/latest \
    | jq -r '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
    | head -n1)

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
    echo "Failed to resolve FreeTube .deb download URL" >&2
    exit 1
fi

curl -fsSL -o /tmp/freetube.deb "$URL"
apt-get install -y /tmp/freetube.deb
rm -f /tmp/freetube.deb

apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_FREETUBE

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
