ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

######################################
# Same as Steam, here we build a patched bubblewrap
# that works with CAP_SYS_ADMIN in containers.
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

ARG LUTRIS_VERSION=0.5.22

# Install RPM Fusion for wine and multimedia codecs
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Wine, 32-bit libs, Python deps, and Lutris dependencies
RUN dnf install -y \
    cabextract \
    curl \
    fluid-soundfont-gm \
    gtk3 gobject-introspection \
    webkit2gtk4.1 \
    gdk-pixbuf2 \
    librsvg2 \
    alsa-plugins-pulseaudio.i686 \
    dbus-libs.i686 \
    freetype.i686 \
    mesa-libGL.i686 \
    mesa-libEGL.i686 \
    sdl2-compat.i686 \
    sqlite-libs.i686 \
    vulkan-loader vulkan-loader.i686 \
    mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
    p7zip \
    python3-dbus \
    python3-distro \
    python3-gobject \
    python3-lxml \
    python3-pillow \
    python3-requests \
    python3-setproctitle \
    python3-pyyaml \
    python3-magic \
    unzip \
    vulkan-tools \
    wine wine.i686 \
    winetricks \
    xrandr \
    zenity \
    lutris \
    && dnf clean all

# Replace system bwrap with patched version that works with CAP_SYS_ADMIN
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

RUN mkdir -pm 777 /var/lutris/ && \
    mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/lutris-system.yml /opt/gow/lutris-system.yml
COPY configs/lutris-lutris.conf /opt/gow/lutris-lutris.conf

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
