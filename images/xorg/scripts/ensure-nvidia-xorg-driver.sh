#!/bin/bash

NVIDIA_DRIVER_MOUNT_LOCATION=/nvidia/xorg
NVIDIA_PACKAGE_LOCATION=/usr/lib/x86_64-linux-gnu/nvidia/xorg

# If the user has requested to skip the check, do so
if [ "${SKIP_NVIDIA_DRIVER_CHECK:-0}" = "1" ]; then
    exit
fi

function fail() {
    (
        if [ ! -z "${1:-}" ]; then
            echo "$1"
        fi
        echo "Xorg may fail to start; try mounting drivers from your host as a volume."
    ) >&2
    exit 1
}

# If there's an nvidia_drv.so in the mount location, or in the location where
# the xserver-xorg-video-nvidia package installs to, assume it's the right one
for d in $NVIDIA_DRIVER_MOUNT_LOCATION $NVIDIA_PACKAGE_LOCATION; do
    if [ -f $d/nvidia_drv.so ]; then
        echo "Found an existing nvidia_drv.so"
        exit
    fi
done

# Otherwise, try to download the correct package.
# Inspired by https://github.com/andrewmackrodt/dockerfiles/blob/master/ubuntu-x11/entrypoint.d/root/start/15-nvidia-driver,
# but only installs the Xorg driver
HOST_DRIVER_VERSION=$(cat /proc/driver/nvidia/version | sed -nE 's/.*Module[ \t]+([0-9]+(\.[0-9]+)?).*/\1/p')
HOST_DRIVER_MAJOR_VERSION=$(echo "$HOST_DRIVER_VERSION" | sed -E 's/\..+//')

XORG_PACKAGE_NAME="xserver-xorg-video-nvidia-$HOST_DRIVER_MAJOR_VERSION"
GL_PACKAGE_NAME="libnvidia-gl-$HOST_DRIVER_MAJOR_VERSION"

add-apt-repository -y ppa:graphics-drivers/ppa &>/dev/null

# ensure the package info is up to date so we have the best chance of finding a
# matching driver
apt-get update &>/dev/null

MAJOR_PACKAGE_APT_VERSIONS=$( \
    apt-cache madison "$XORG_PACKAGE_NAME" \
        | awk '{ print $3 }' \
        | sort -rV
    )

PACKAGE_APT_VERSION=$( \
    echo "$MAJOR_PACKAGE_APT_VERSIONS" \
        | grep "$HOST_DRIVER_VERSION" \
        | head -n1 \
    )

if [ -z "$PACKAGE_APT_VERSION" ]; then
    fail "Failed to locate a package with the same driver version ($HOST_DRIVER_VERSION)"
fi

# tell dpkg to install the given file somewhere else so it doesn't try to
# overwrite a bind-mounted file.
function create_a_diversion() {
    local mounted=$1

    dir=$(dirname "$mounted")
    file=$(basename "$mounted")

    diverted_dir="$dir/distro"

    # make sure the diverted location exists, or dpkg will fail when trying to
    # write to it.
    mkdir -p "$diverted_dir"

    diverted="$diverted_dir/$file"

    # echo "Diverting $a => $diverted"
    dpkg-divert --no-rename --divert "$diverted" "$a" &>/dev/null
}

# for each of the driver files nvidia-docker mounts in for us, tell dpkg not to
# overwrite them when installing packages.
for a in $(mount | grep "\.so\.$HOST_DRIVER_VERSION" | cut -f 3 -d ' '); do
    create_a_diversion "$a"
done

echo -n "Installing Nvidia X driver ($PACKAGE_APT_VERSION)..."
apt-get install -qqy --no-install-recommends "$XORG_PACKAGE_NAME=$PACKAGE_APT_VERSION" "$GL_PACKAGE_NAME=$PACKAGE_APT_VERSION" &>/dev/null
if [ $? -ne 0 ]; then
    echo "error!"
    fail "The Nvidia X driver could not be automatically installed."
else
    echo "done."
fi

