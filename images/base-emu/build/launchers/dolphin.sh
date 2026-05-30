#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/dolphin-emu.AppImage"
gow_log "Starting dolphin-emu DISPLAY=${DISPLAY} args: $*"

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run --fullscreen
fi

if [[ "${1:-}" == --exec && -n "${2:-}" ]]; then
    exec "$APP" --appimage-extract-and-run --batch --fullscreen --exec="$2"
fi

if [[ "${1:-}" == --exec=* ]]; then
    exec "$APP" --appimage-extract-and-run --batch --fullscreen "$1"
fi

exec "$APP" --appimage-extract-and-run --batch --fullscreen --exec="$1"
