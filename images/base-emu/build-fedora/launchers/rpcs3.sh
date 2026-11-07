#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting RPCS3 with DISPLAY=${DISPLAY}"
/Applications/rpcs3-emu.AppImage --appimage-extract-and-run