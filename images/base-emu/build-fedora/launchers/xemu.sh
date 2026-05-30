#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/xemu-emu.AppImage"
gow_log "Starting Xemu DISPLAY=${DISPLAY} args: $*"

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run -full-screen
fi

if [[ "${1:-}" != -* ]]; then
    exec "$APP" --appimage-extract-and-run -full-screen -dvd_path "$1"
fi

exec "$APP" --appimage-extract-and-run -full-screen "$@"
