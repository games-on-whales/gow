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

# Install software to mount iso/zip
RUN \
    echo "**** Install mount iso & zip dependencies ****" && \
        apt-get update && \
        apt-get install -y \
            fuseiso \
            fuse-zip \
            && \
    # Cleanup \
		apt-get autoremove -y && \
		rm -rf /var/lib/apt/lists/*

# Setup ISO mounting location
RUN mkdir -p /media/iso_mount && chown 1000:1000 /media/iso_mount

# Install pegasus
RUN  <<_INSTALL_PEGASUS
#!/bin/bash
set -e

echo "**** Installing pegasus ****"
apt-get update -y

# Create a dummy policykit-1 package to satisfy the dependency
mkdir -p /tmp/policykit-dummy/DEBIAN
cat > /tmp/policykit-dummy/DEBIAN/control << 'EOF'
Package: policykit-1
Version: 999.0
Architecture: amd64
Maintainer: Dummy Package
Description: Transitional dummy package for policykit-1
Depends: polkitd, pkexec
Provides: policykit-1
Replaces: policykit-1
Conflicts: policykit-1
EOF

dpkg-deb --build /tmp/policykit-dummy /tmp/policykit-1_999.0_amd64.deb
dpkg -i /tmp/policykit-1_999.0_amd64.deb

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
