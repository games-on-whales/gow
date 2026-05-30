#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/pcsx2-emu.AppImage"
gow_log "Starting PCSX2 DISPLAY=${DISPLAY} args: $*"

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run -fullscreen
fi

exec "$APP" --appimage-extract-and-run -fullscreen "$@"
