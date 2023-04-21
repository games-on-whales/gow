#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Set DISPLAY to 0"
export DISPLAY=:0

gow_log "Configure xhost for all hosts"
xhost +

gow_log "Launching EmulationStation-DE"
exec /usr/bin/emulationstation