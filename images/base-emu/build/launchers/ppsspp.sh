#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting PPSSPP with DISPLAY=${DISPLAY}"
/Applications/ppsspp-emu.AppImage --appimage-extract-and-run