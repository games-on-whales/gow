#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting XEMU with DISPLAY=${DISPLAY}"
cd /Applications
./xemu-emu.AppImage --appimage-extract-and-run
#xemu