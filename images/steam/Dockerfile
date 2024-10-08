ARG BASE_APP_IMAGE

######################################
# The issue here is, that you don't want to give privileged,
# but bwrap needs CAP_SYS_ADMIN.
# However if you explicitly give CAP_SYS_ADMIN, bwrap throws an error,
# because it detects that capabilities have been tempered with
FROM ubuntu:22.04 AS bwrap-builder

ENV DEBIAN_FRONTEND=non-interactive
WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git meson ca-certificates dpkg-dev && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    ./ci/builddeps.sh && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson _builddir && \
    meson compile -C _builddir

######################################

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Recent libc6 versions are failing to install, so we install manually an old version
# The issue seems to be common, telinit gets stuck after "Setting up libc6:i386"
# This might be related https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1060387
# Here's an example of a failed workflow: https://github.com/games-on-whales/gow/actions/runs/8057975030/job/22010078389
RUN <<_FIX_LIBC6
set -e
dpkg --add-architecture i386
apt-get update -y
apt-get install -y --no-install-recommends libc6:amd64 libc6:i386

# Cleanup
rm -rf /var/lib/apt/lists/*
_FIX_LIBC6

ARG REQUIRED_PACKAGES=" \
    steam \
    libvulkan1 libvulkan1:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    libgbm1:i386 libgles2:i386 libegl1:i386 libgl1-mesa-dri:i386 libgl1:i386 libglapi-mesa:i386 libglx0:i386 \
    libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 libcurl4 libcurl4:i386 \
    dbus-daemon dbus-system-bus-common dbus-session-bus-common whoopsie network-manager bluez \
    mangoapp ibus curl pkexec xz-utils zenity file xdg-user-dirs xdg-utils lsof pciutils lsb-release mesa-utils \
    libfontconfig1:i386 libfontconfig1:amd64 libfreetype6 libfreetype6:i386 \
"

RUN apt-get update -y && \
    apt-get install -y python3-six software-properties-common && \
    # \
    # Install steam (Steam is 32-bit only) \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # \
    # Fix steam updater UI font file \
    ln -s /usr/share/fonts/truetype/dejavu /usr/share/fonts/truetype/ttf-dejavu && \
    # \
    # Cleanup \
    apt-get remove -y python3-six software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
# fix NetworkManager not picking up devices
RUN touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf

# skip annoying debian dialog
RUN rm /usr/bin/zenity && ln -s /usr/bin/true /usr/bin/zenity

# refresh system font cache. For font warnings on startup see: https://github.com/ValveSoftware/steam-runtime/issues/482
RUN fc-cache -f -v

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/system-services.sh /etc/cont-init.d/system-services.sh
COPY --chmod=777 steamos-update /usr/bin/steamos-update
COPY --chmod=777 steamos-update /usr/bin/steamos-polkit-helpers/steamos-update
COPY --chmod=777 steamos-session-select /usr/bin/steamos-session-select
COPY --chmod=777 jupiter-biosupdate /usr/bin/jupiter-biosupdate
COPY --chmod=777 jupiter-biosupdate /usr/bin/steamos-polkit-helpers/jupiter-biosupdate
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
