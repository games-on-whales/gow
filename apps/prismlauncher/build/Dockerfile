ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# install all needed java runtimes.
ARG REQUIRED_PACKAGES=" \
    openjdk-21-jre \
    openjdk-17-jre \
    openjdk-8-jre \
    "

RUN apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Install PrismLauncher from official GitHub releases (portable Qt6 build).
# Avoids the community PPA which has had broken plucky packages.
RUN <<_INSTALL_PRISM
#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

github_download "PrismLauncher/PrismLauncher" \
  ".assets[]|select(.name|test(\"Linux-Qt6-Portable.*\\.tar\\.gz$\")).browser_download_url" \
  "PrismLauncher-portable.tar.gz"

mkdir -p /opt/prismlauncher
tar xf PrismLauncher-portable.tar.gz -C /opt/prismlauncher
rm PrismLauncher-portable.tar.gz

chmod +x /opt/prismlauncher/PrismLauncher /opt/prismlauncher/bin/prismlauncher

# Expose as 'prismlauncher' in PATH (startup.sh calls 'prismlauncher')
ln -sf /opt/prismlauncher/PrismLauncher /usr/local/bin/prismlauncher
_INSTALL_PRISM

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
