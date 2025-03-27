#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Citron with DISPLAY=${DISPLAY}"
/Applications/citron-emu.AppImage --appimage-extract-and-run