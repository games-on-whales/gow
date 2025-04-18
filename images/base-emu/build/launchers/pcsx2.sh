#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting PCSX2-QT with DISPLAY=${DISPLAY}"
mangohud /Applications/pcsx2-emu.AppImage --appimage-extract-and-run