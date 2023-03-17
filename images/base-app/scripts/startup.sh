#!/bin/bash

set -e

source /opt/gow/bash-lib/utils.sh

# Launch the container's startup script
if [ -z "$RUN_GAMESCOPE" ]; then
    gow_log "Waiting for X Server $DISPLAY to be available"
    /opt/gow/wait-x11
    exec /opt/gow/startup-app.sh
else
    /usr/games/gamescope -b -- exec /opt/gow/startup-app.sh
fi
