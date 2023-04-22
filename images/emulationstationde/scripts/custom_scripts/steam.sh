#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Steam with DISPLAY=${DISPLAY}"
mkdir -p "$HOME/.steam/ubuntu12_32/steam-runtime"
exec /usr/games/steam -oldbigpicture -bigpicture