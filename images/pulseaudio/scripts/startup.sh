#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

mkdir -p /home/retro/.config/pulse
rm -f /home/retro/.config/pulse/*

LOG "Starting pulseaudio"
pulseaudio --log-level=1 #--log-target=stderr -v
