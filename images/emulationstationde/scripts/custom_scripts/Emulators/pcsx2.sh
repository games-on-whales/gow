#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting PCSX2-QT with DISPLAY=${DISPLAY}"
cd /home/retro/Applications
./pcsx2-emu-Qt.AppImage
#pcsx2-qt