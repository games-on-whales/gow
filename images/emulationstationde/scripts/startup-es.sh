#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Configure xhost for all hosts"
export DISPLAY=:0
xhost +

gow_log "Launching EmulationStation-DE"
exec /usr/bin/emulationstation --no-update-check --gamelist-only