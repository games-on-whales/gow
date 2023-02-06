#!/bin/bash
set -e

start_udev() {
	# mount_dev
    if command -v udevd &>/dev/null; then
        unshare --net udevd --daemon &> /dev/null
    else
        unshare --net /lib/systemd/systemd-udevd --daemon &> /dev/null
    fi
    udevadm trigger &> /dev/null
}

start_udev
exec udevadm monitor
