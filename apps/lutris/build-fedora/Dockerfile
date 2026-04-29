ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

######################################
# Same as Steam, here we build a patched bubblewrap
# that works with CAP_SYS_ADMIN in containers.
FROM ${BASE_APP_IMAGE} AS bwrap-builder

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
ARG GAMEPAD_UI_VERSION=v0.1.34

# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

# Install RPM Fusion for wine and multimedia codecs
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Wine, 32-bit libs, Python deps, and Lutris dependencies
RUN dnf install -y --allowerasing \
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
    ffmpeg ffmpeg-libs libavcodec-freeworld \
    ffmpeg-libs.i686 libavcodec-freeworld.i686 \
    && dnf clean all

# Replace system bwrap with patched version that works with CAP_SYS_ADMIN
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

# Install Lutris Gamepad UI
ENV APPIMAGE_URL="https://github.com/andrew-ld/lutris-gamepad-ui/releases/download/${GAMEPAD_UI_VERSION}/lutris-gamepad-ui-x64.AppImage"
ENV APP_DIR="/opt/gow/app"

# Download and extract AppImage
#COPY --chmod=777 release.AppImage /tmp/app.AppImage
RUN curl -LJ ${APPIMAGE_URL} -o /tmp/app.AppImage && \
    chmod +x /tmp/app.AppImage && \
    /tmp/app.AppImage --appimage-extract && \
    mv squashfs-root ${APP_DIR} && \
    rm -rf /tmp/app.AppImage && \
    chown -R 1000:1000 ${APP_DIR}

RUN mkdir -pm 777 /var/lutris/ && \
    mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/startup-10-create-dirs.sh /opt/gow/startup.d/10-create-dirs.sh
COPY configs/lutris-system.yml /opt/gow/lutris-system.yml
COPY configs/lutris-lutris.conf /opt/gow/lutris-lutris.conf
COPY configs/gamepadui.json /opt/gow/gamepadui.json

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
