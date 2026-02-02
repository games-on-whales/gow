#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Ares-emu with DISPLAY=${DISPLAY}"
/Applications/ares-emu.AppImage --appimage-extract-and-run
