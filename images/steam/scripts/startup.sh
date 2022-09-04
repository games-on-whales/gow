#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Steam with DISPLAY=${DISPLAY}"

# Recursively creating Steam necessary folders (https://github.com/ValveSoftware/steam-for-linux/issues/6492)
mkdir -p $HOME/.steam/ubuntu12_32/steam-runtime

# Start Steam. Use `sudo` to make sure that group membership gets reloaded
exec /usr/games/steam
