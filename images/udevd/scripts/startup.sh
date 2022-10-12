#!/bin/bash

set -e

source /opt/gow/bash-lib/utils.sh

function start_udev() {
	# mount_dev
    if command -v udevd &>/dev/null; then
        nsenter udevd --daemon &> /dev/null
    else
        nsenter /lib/systemd/systemd-udevd --daemon &> /dev/null
    fi
    udevadm trigger &> /dev/null || true
}

start_udev

if [ "${UDEVD_QUIET:-false}" = "true" ]; then
    # redirect stdout to /dev/null before running udevadm monitor
    exec >/dev/null
fi

exec udevadm monitor
