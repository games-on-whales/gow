#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

LOG "Waiting for X Server $DISPLAY to be available"
wait-x11

LOG "Starting Steam with DISPLAY=${DISPLAY}"

ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

# Recursively creating Steam necessary folders (https://github.com/ValveSoftware/steam-for-linux/issues/6492)
mkdir -p $HOME/.steam/ubuntu12_32/steam-runtime

# Start Steam. Use `sudo` to make sure that group membership gets reloaded
exec sudo -u $(whoami) -E /usr/games/steam
