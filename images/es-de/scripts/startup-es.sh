#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh
source /opt/gow/launch-comp.sh

gow_log "Launching EmulationStation-Desktop Edition"
launcher "/Applications/esde.AppImage --appimage-extract-and-run --no-update-check"
