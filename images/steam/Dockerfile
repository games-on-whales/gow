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

ARG REQUIRED_PACKAGES=" \
    steam \
    libvulkan1 libvulkan1:i386 \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    libdbus-1-3 libgtk-3-0 libegl1 libsdl2-2.0-0 \
    dbus-daemon dbus-system-bus-common dbus-session-bus-common whoopsie network-manager bluez \
    mangoapp ibus \
"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common && \
    # \
    # Install steam (Steam is 32-bit only) \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
# fix NetworkManager not picking up devices
RUN touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/system-services.sh /etc/cont-init.d/system-services.sh
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
