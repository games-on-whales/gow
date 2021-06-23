#!/bin/bash

NVIDIA_DRIVER_MOUNT_LOCATION=/nvidia/xorg
NVIDIA_PACKAGE_LOCATION=/usr/lib/x86_64-linux-gnu/nvidia/xorg

# If the user has requested to skip the check, do so
if [ "${NVIDIA_SKIP_DRIVER_CHECK:-0}" = "1" ]; then
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

PACKAGE_NAME="xserver-xorg-video-nvidia-$HOST_DRIVER_MAJOR_VERSION"

MAJOR_PACKAGE_APT_VERSIONS=$( \
    apt-cache madison "$PACKAGE_NAME" \
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

cd /tmp

DUMMY_NAME=nvidia-dummy
DUMMY_FILE=${DUMMY_NAME}_1.0_all.deb

__ticks=0
function tick() {
    __ticks=$((__ticks+1))
    echo -ne "\rWorking: " >&3
    printf '.%.0s' $(seq 1 $__ticks) >&3
    if [ ${1:-} = "last" ]; then
        echo -ne "\n" >&3
    fi
}

function build_dummy() {
    echo "Telling APT about the host driver (this may take a while)..."
    (
        set -e # fail early
        tick
        cat << CONTROL >${DUMMY_NAME}.control
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: ${DUMMY_NAME}
Provides: libnvidia-cfg1-${HOST_DRIVER_MAJOR_VERSION} (= ${PACKAGE_APT_VERSION})
Description: Placeholder for nvidia-docker provided libs
 Since nvidia-docker provides most of the required drivers, this package tells APT about the current version for dependency purposes.
CONTROL
        tick
        apt-get -qqy --no-install-recommends install equivs; tick
        equivs-build ${DUMMY_NAME}.control; tick
        apt-get -qqy remove equivs; tick
        apt-get -qqy remove --autoremove; tick
        dpkg -i ${DUMMY_FILE}; tick
        rm ${DUMMY_NAME}.control ${DUMMY_FILE}; tick last
    ) 3>&1 &>/dev/null
}

if build_dummy; then
    echo "Installing Nvidia X driver ($PACKAGE_APT_VERSION)..."
    apt-get install -qqy --no-install-recommends "$PACKAGE_NAME=$PACKAGE_APT_VERSION" >/dev/null
else
    fail "The Nvidia X driver could not be automatically installed."
fi
