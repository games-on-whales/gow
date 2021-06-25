#!/bin/bash

DUMMY_PACKAGE_CACHE=/var/cache/dummy

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

mkdir -p $DUMMY_PACKAGE_CACHE
cd $DUMMY_PACKAGE_CACHE

DUMMY_NAME=nvidia-dummy
DUMMY_VERSION=${HOST_DRIVER_VERSION}
DUMMY_FILE=${DUMMY_NAME}_${DUMMY_VERSION}_all.deb

__ticks=0
function tick() {
    __ticks=$((__ticks+1))
    echo -ne "\rWorking: " >&3
    printf '.%.0s' $(seq 1 $__ticks) >&3
    if [ "${1:-}" = "last" ]; then
        echo -ne "\n" >&3
    fi
}

function build_dummy() {
    echo "Telling APT about the host driver (this may take a while)"
    (
        # exit the subshell early if any of the commands fail.
        set -e; tick

        # Create a `control` file for use by equivs to build the dummy package.
        # We do this manually instead of using equivs-build because it's easier
        # than editing in the custom values later.
        cat << CONTROL >${DUMMY_NAME}.control
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: ${DUMMY_NAME}
Version: ${DUMMY_VERSION}
Provides: libnvidia-cfg1-${HOST_DRIVER_MAJOR_VERSION} (= ${PACKAGE_APT_VERSION})
Description: Placeholder for nvidia-docker provided libs
 Since nvidia-docker provides most of the required drivers, this package tells APT about the current version for dependency purposes.
CONTROL
        tick

        # Install equivs
        apt-get update; tick
        apt-get -qqy --no-install-recommends install equivs; tick

        # Build the dummy package
        equivs-build ${DUMMY_NAME}.control; tick
        rm ${DUMMY_NAME}.control; tick

        # Clean up all the extra junk we don't need anymore.
        apt-get -qqy remove equivs; tick
        apt-get -qqy remove --autoremove; tick last
    ) 3>&1 &>/dev/null
}

# If there's already a dummy package with the appropriate version, just use it
# instead of rebuilding.
if [ -f "$DUMMY_PACKAGE_CACHE/${DUMMY_FILE}" ]; then
    echo "Telling APT about the host driver (cached)"
else
    if ! build_dummy; then
        fail "Could not generate dependencies"
    fi
fi

if dpkg -i ${DUMMY_FILE} &>/dev/null; then
    echo -n "Installing Nvidia X driver ($PACKAGE_APT_VERSION)..."
    apt-get install -qqy --no-install-recommends "$PACKAGE_NAME=$PACKAGE_APT_VERSION" &>/dev/null
    echo "done."
else
    fail "The Nvidia X driver could not be automatically installed."
fi


