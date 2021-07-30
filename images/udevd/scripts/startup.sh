#!/bin/bash
# Taken from https://github.com/balena-io-library/base-images/blob/master/balena-base-images/amd64/ubuntu/focal/build/entry.sh

# This command only works in privileged container
# tmp_mount='/tmp/_balena'
# mkdir -p "$tmp_mount"
# if mount -t devtmpfs none "$tmp_mount" &> /dev/null; then
# 	PRIVILEGED=true
# 	umount "$tmp_mount"
# else
# 	PRIVILEGED=false
# fi
# rm -rf "$tmp_mount"

# function mount_dev()
# {
# 	tmp_dir='/tmp/tmpmount'
# 	mkdir -p "$tmp_dir"
# 	mount -t devtmpfs none "$tmp_dir"
# 	mkdir -p "$tmp_dir/shm"
# 	mount --move /dev/shm "$tmp_dir/shm"
# 	mkdir -p "$tmp_dir/mqueue"
# 	mount --move /dev/mqueue "$tmp_dir/mqueue"
# 	mkdir -p "$tmp_dir/pts"
# 	mount --move /dev/pts "$tmp_dir/pts"
# 	touch "$tmp_dir/console"
# 	mount --move /dev/console "$tmp_dir/console"
# 	umount /dev || true
# 	mount --move "$tmp_dir" /dev

# 	# Since the devpts is mounted with -o newinstance by Docker, we need to make
# 	# /dev/ptmx point to its ptmx.
# 	# ref: https://www.kernel.org/doc/Documentation/filesystems/devpts.txt
# 	ln -sf /dev/pts/ptmx /dev/ptmx
# 	mount -t debugfs nodev /sys/kernel/debug
# }

function start_udev()
{
	# mount_dev
    if command -v udevd &>/dev/null; then
        unshare --net udevd --daemon &> /dev/null
    else
        unshare --net /lib/systemd/systemd-udevd --daemon &> /dev/null
    fi
    udevadm trigger &> /dev/null
}

start_udev
udevadm monitor