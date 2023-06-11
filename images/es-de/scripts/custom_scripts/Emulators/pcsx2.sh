#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting PCSX2-QT with DISPLAY=${DISPLAY}"
cd /home/retro/Applications
./pcsx2-emu-Qt.AppImage --appimage-extract-and-run
#pcsx2-qt