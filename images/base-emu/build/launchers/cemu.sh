#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/cemu-emu.AppImage"
gow_log "Starting Cemu DISPLAY=${DISPLAY} args: $*"

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run -f
fi

if [[ "${1:-}" == -g && -n "${2:-}" ]]; then
    exec "$APP" --appimage-extract-and-run -f -g "$2"
fi

exec "$APP" --appimage-extract-and-run -f "$@"
