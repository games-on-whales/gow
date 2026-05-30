#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

APP="/Applications/citron.AppImage"
gow_log "Starting Citron DISPLAY=${DISPLAY} args: $*"

if [[ ! -f "$APP" ]]; then
    gow_log "ERROR: Citron AppImage missing at ${APP} (not bundled in current ES-DE image)"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    exec "$APP" --appimage-extract-and-run -f
fi

for arg in "$@"; do
    if [[ "$arg" == "-f" || "$arg" == "--fullscreen" ]]; then
        exec "$APP" --appimage-extract-and-run "$@"
    fi
done

exec "$APP" --appimage-extract-and-run -f "$@"
