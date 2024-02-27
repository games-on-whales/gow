#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting YUZU with DISPLAY=${DISPLAY}"
cd /Applications
./yuzu-emu.AppImage --appimage-extract-and-run
