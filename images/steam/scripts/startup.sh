#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Steam with DISPLAY=${DISPLAY}"

# Recursively creating Steam necessary folders (https://github.com/ValveSoftware/steam-for-linux/issues/6492)
mkdir -p "$HOME/.steam/ubuntu12_32/steam-runtime"

# Start Steam
if [ -z "$RUN_GAMESCOPE" ]; then
  exec /usr/games/steam
else
  /usr/games/gamescope -b -- /usr/games/steam -oldbigpicture -bigpicture
fi
