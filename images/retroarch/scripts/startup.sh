#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

LOG "Waiting for X Server $DISPLAY to be available"
wait-x11


LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG "Starting RetroArch with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

# Copying config in case it's the first time we mount from the host
mkdir -p $HOME/retroarch/
cp -u /cfg/retroarch.cfg $HOME/retroarch/retroarch.cfg

# Start Retroarch. Use `sudo` to make sure that group membership gets reloaded
exec sudo -u $(whoami) -E /usr/bin/retroarch \
    --config /home/retro/retroarch/retroarch.cfg \
    # --verbose
