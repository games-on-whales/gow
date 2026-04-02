ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# see: https://github.com/AppImage/AppImageKit/wiki/FUSE#docker
ENV APPIMAGE_EXTRACT_AND_RUN=1

#GitHub REST query versioning
ARG GITHUB_REST_VERSION=2022-11-28

# Install prereqs
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y \
    curl \
    ffmpeg \
    jq \
    dbus-libs \
    mesa-libEGL \
    mesa-libGLU \
    gtk3 \
    SDL2 \
    vulkan-loader \
    p7zip \
    qt5-qtbase \
    qt6-qtbase \
    wget \
    xorg-x11-server-utils \
    libaio \
    libusb1 \
    xz \
    retroarch \
    && dnf clean all

RUN <<_INSTALL_EMULATORS
#!/bin/bash
set -e

EMULATORS_DIR=/Applications
mkdir -p $EMULATORS_DIR
cd $EMULATORS_DIR

github_download(){
    local repo="$1"
    local out_file="$2"
    local extra_filter="$3"
    local api_suffix="$4"
    local ext=".${out_file##*.}"
    local url="https://api.github.com/repos/${repo}/releases${api_suffix}"
    local jq_prefix=""
    if [ -z "$api_suffix" ]; then
        jq_prefix='[.[] | select(.prerelease==false and .draft==false)][0]'
    fi
    curl -s "$url" | \
    jq "${jq_prefix}.assets[]|select(.name|endswith(\"${ext}\"))${extra_filter}.browser_download_url" | \
    xargs wget -O "$out_file"
}

gitlab_download(){
    local gitlab_url="$1"
    local out_file="$2"
    local extra_filter="$3"

    local gitlab_instance=$(echo "$gitlab_url" | sed 's|https://\([^/]*\).*|\1|')
    local project_path=$(echo "$gitlab_url" | sed 's|https://[^/]*/||')
    local api_url="https://${gitlab_instance}/api/v4/projects/${project_path//\//%2F}/releases"

    local download_url=$(curl -s "$api_url" | \
        jq '.[0].assets.links[] | select(.name | contains("'${extra_filter}'")) | .direct_asset_url' | \
        tr -d '"')

    if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
        echo "No matching download found for ${out_file} with filter: ${extra_filter}"
        return 1
    fi

    wget -O "$out_file" "$download_url"
}

forgejo_download(){
    local forgejo_url="$1"
    local out_file="$2"
    local extra_filter="$3"

    local forgejo_instance=$(echo "$forgejo_url" | sed 's|https://\([^/]*\).*|\1|')
    local project_path=$(echo "$forgejo_url" | sed 's|https://[^/]*/||')

    local owner=$(echo "$project_path" | cut -d'/' -f1)
    local repo=$(echo "$project_path" | cut -d'/' -f2)

    local api_url="https://${forgejo_instance}/api/v1/repos/${owner}/${repo}/releases"

    local download_url=$(curl -s "$api_url" | jq -r '.[] | .assets[]?.browser_download_url' | grep "$extra_filter" | head -n 1)

    if [ -z "$download_url" ]; then
        echo "No matching download found for ${out_file} with filter: ${extra_filter}"
        return 1
    fi

    wget -O "$out_file" "$download_url"
}


echo "**** Downloading PCSX2 AppImage ****"
github_download "PCSX2/pcsx2" "pcsx2-emu.AppImage" "" "/latest"

echo "**** Downloading XEMU AppImage ****"
github_download "xemu-project/xemu" "xemu-emu.AppImage" "|select(.name|contains(\"dbg\")|not)|select(.name|contains(\"x86_64\"))" "/latest"

echo "**** Downloading RPCS3 AppImage ****"
github_download "rpcs3/rpcs3-binaries-linux" "rpcs3-emu.AppImage" "" "/latest"

echo "**** Downloading CEMU AppImage ****"
github_download "cemu-project/Cemu" "cemu-emu.AppImage" "" "/latest"

echo "**** Downloading Dolphin AppImage ****"
github_download "pkgforge-dev/Dolphin-emu-AppImage" "dolphin-emu.AppImage" "|select(.name|contains(\"zsync\")|not)|select(.name|contains(\"x86_64.AppImage\"))"

echo "**** Downloading Citron Emulator AppImage ****"
# TODO: check why this is failing
#forgejo_download "https://git.citron-emu.org/citron-emu/Citron" "citron.AppImage" "x86_64"

echo "**** Downloading Xenia Canary ****"
github_download "xenia-canary/xenia-canary-releases" "xenia_canary_linux.tar.xz" "" ""

echo "**** Extracting Xenia Canary ****"
mkdir -p xenia-canary
tar -xf xenia_canary_linux.tar.xz -C xenia-canary
rm xenia_canary_linux.tar.xz

chmod -v -R 777 $EMULATORS_DIR
chmod -v -R a+x $EMULATORS_DIR
_INSTALL_EMULATORS

COPY --chmod=777 launchers /Applications/launchers
ENV PATH="/Applications/launchers:${PATH}"

RUN \
    echo "**** Preparing /bioses for symlinking ****" && \
        mkdir -pm755 /bioses

RUN \
    echo "**** Preparing /ROMs for symlinking ****" && \
        mkdir -pm755 /ROMs

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
