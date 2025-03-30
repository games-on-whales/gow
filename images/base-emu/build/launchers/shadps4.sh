#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting ShadPS4 with DISPLAY=${DISPLAY}"
mangohud /Applications/Shadps4-qt.AppImage --appimage-extract-and-run