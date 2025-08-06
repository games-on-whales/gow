#!/bin/bash
# SteamVR launcher script

source /opt/gow/bash-lib/utils.sh

gow_log "Starting SteamVR..."

# Set VR environment
export STEAM_VR=1
export VR_OVERRIDE=/home/retro/.steam/steam/steamapps/common/SteamVR

# Launch SteamVR directly
if [ -f "$VR_OVERRIDE/bin/linux64/vrstartup.sh" ]; then
    gow_log "Launching SteamVR directly..."
    exec "$VR_OVERRIDE/bin/linux64/vrstartup.sh"
else
    gow_log "Launching SteamVR via Steam..."
    exec /usr/games/steam -applaunch 250820
fi
