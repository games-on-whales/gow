#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

# Cleanup in case we are restarting the container
rm -f ~/.config/pulse/*

LOG "Starting pulseaudio"
pulseaudio # --log-level=4 --log-target=stderr -v
