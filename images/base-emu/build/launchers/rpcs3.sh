#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/rpcs3-emu.AppImage"
gow_log "Starting RPCS3 DISPLAY=${DISPLAY} args: $*"

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run
fi

exec "$APP" --appimage-extract-and-run "$@"
