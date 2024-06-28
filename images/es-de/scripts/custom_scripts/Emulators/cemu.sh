#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting CEMU with DISPLAY=${DISPLAY}"
cd /Applications
./cemu-emu.AppImage --appimage-extract-and-run