#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Eden with DISPLAY=${DISPLAY}"
# `-f` launches Eden fullscreen. Eden persists `fullscreen=false` to its config
# on a windowed exit, so we force it on every launch; F11 still toggles within a
# session. Extra args (e.g. `-g <rom>` from rom_launcher) are passed through.
/Applications/eden.AppImage --appimage-extract-and-run -f "$@"
