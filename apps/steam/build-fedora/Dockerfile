ARG BASE_APP_IMAGE

######################################
# The issue here is, that you don't want to give privileged,
# but bwrap needs CAP_SYS_ADMIN.
# However if you explicitly give CAP_SYS_ADMIN, bwrap throws an error,
# because it detects that capabilities have been tempered with
FROM fedora:43 AS bwrap-builder

WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN dnf install -y git meson ca-certificates dpkg-dev && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    ./ci/builddeps.sh && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson _builddir && \
    meson compile -C _builddir

######################################

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

RUN <<_INSTALL_STEAM
#!/bin/bash
set -e

# Taken from https://docs.fedoraproject.org/en-US/gaming/proton/
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Install Steam
dnf install -y steam

# Additional packages
dnf install -y NetworkManager bluez ibus pkexec file pciutils lsb-release

# Cleanup
# We'll be using a custom steam startup script, the default `steam` script that comes from Fedora was failing
rm $(which steam)
dnf clean all
_INSTALL_STEAM

# create symlink for improved decky loader compatibility
RUN ln -sf "$HOME" /home/deck

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/system-services.sh /etc/cont-init.d/system-services.sh
COPY --chmod=777 steamos-update /usr/bin/steamos-update
COPY --chmod=777 steamos-update /usr/bin/steamos-polkit-helpers/steamos-update
COPY --chmod=777 steamos-session-select /usr/bin/steamos-session-select
COPY --chmod=777 jupiter-biosupdate /usr/bin/jupiter-biosupdate
COPY --chmod=777 jupiter-biosupdate /usr/bin/steamos-polkit-helpers/jupiter-biosupdate
COPY --chmod=777 scripts/steamos-dbus-watchdog.sh /usr/local/bin/steamos-dbus-watchdog.sh
COPY --chmod=777 scripts/steam.sh /usr/games/steam
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
