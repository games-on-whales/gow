#!/bin/bash

NVIDIA_DRIVER_MOUNT_LOCATION=/nvidia/xorg
NVIDIA_PACKAGE_LOCATION=/usr/lib/x86_64-linux-gnu/nvidia/xorg

# If the user has requested to skip the check, do so
if [ "${SKIP_NVIDIA_DRIVER_CHECK:-0}" = "1" ]; then
    exit
fi

function fail() {
    (
        if [ -n "${1:-}" ]; then
            echo "$1"
        fi
        echo "Xorg may fail to start; try mounting drivers from your host as a volume."
    ) >&2
    exit 1
}

# If there's an nvidia_drv.so in the mount location, or in the location where
# the xserver-xorg-video-nvidia package installs to, assume it's the right one
for d in $NVIDIA_DRIVER_MOUNT_LOCATION $NVIDIA_PACKAGE_LOCATION; do
    if [ -f "$d/nvidia_drv.so" ]; then
        echo "Found an existing nvidia_drv.so"
        exit
    fi
done

# Otherwise, try to download the correct package.
HOST_DRIVER_VERSION=$(sed -nE 's/.*Module[ \t]+([0-9]+(\.[0-9]+)*).*/\1/p' /proc/driver/nvidia/version)

if [ -z "$HOST_DRIVER_VERSION" ]; then
    echo "Could not find NVIDIA driver; skipping"
    exit 0
else
    echo "Looking for driver version $HOST_DRIVER_VERSION"
fi

function download_pkg() {
    dl_url=$1
    dl_file=$2

    echo "Downloading $dl_url"

    if ! wget -q -nc --show-progress --progress=bar:force:noscroll -O "$dl_file" "$dl_url"; then
        echo "ERROR: Unable to download $dl_file"
        return 1
    fi
}

DOWNLOAD_URL=https://us.download.nvidia.com/XFree86/Linux-x86_64/$HOST_DRIVER_VERSION/NVIDIA-Linux-x86_64-$HOST_DRIVER_VERSION.run
DL_FILE=/tmp/nvidia-$HOST_DRIVER_VERSION.run
EXTRACT_LOC=/tmp/nvidia-drv

if [ ! -d $EXTRACT_LOC ]; then
    if ! download_pkg "$DOWNLOAD_URL" "$DL_FILE"; then
        echo "Couldn't download nvidia driver version $HOST_DRIVER_VERSION"
        exit 1
    fi

    chmod +x "$DL_FILE"
    $DL_FILE -x --target $EXTRACT_LOC
    rm "$DL_FILE"
fi

if [ ! -d $NVIDIA_DRIVER_MOUNT_LOCATION ]; then
    mkdir -p $NVIDIA_DRIVER_MOUNT_LOCATION
fi

cp "$EXTRACT_LOC/nvidia_drv.so" "$EXTRACT_LOC/libglxserver_nvidia.so.$HOST_DRIVER_VERSION" "$NVIDIA_DRIVER_MOUNT_LOCATION"



