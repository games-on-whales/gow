ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

# Install prereqs
RUN \
    echo "**** Install Prereqs ****" && \
        apt-get update && \
        apt-get install -y \
            libgstreamer-gl1.0-0 \
            && \
	# Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Install pegasus
RUN  <<_INSTALL_PEGASUS
  #!/bin/bash
  set -e

  echo "**** Installing pegasus ****"
  apt-get update -y

  # Pegasus still requires libssl1.1, but ubuntu switched to libssl3. Need to manually install it.
  # TODO: Doing this could be a terrible idea (it does work)
  wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb --output-document=libssl1.1.deb
  apt-get install -y ./libssl1.1.deb

  # Pegasus doesn't tag releases, they have a rolling weekly release
  # so we have to parse the Github APIs to get the link
  curl -s https://api.github.com/repos/mmatyas/pegasus-frontend/releases/tags/continuous | \
  jq -r '.assets[] | select(.name | contains(".deb")) | .browser_download_url' | \
  xargs curl -fsSL -o pegasus.deb

  apt-get install -y ./pegasus.deb

  # Cleanup
  rm pegasus.deb libssl1.1.deb
  rm -rf /var/lib/apt/lists/*
_INSTALL_PEGASUS

# Copy config files
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/pegasus.sh /bin/pegasus.sh

# Copy Pegasus related files
COPY scripts/tools/*.sh /bin/
COPY configs /cfg

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
