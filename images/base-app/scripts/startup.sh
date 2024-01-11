#!/bin/bash

set -e

source /opt/gow/bash-lib/utils.sh

# Launch the container's startup script
if [ -f "$DISPLAY" ]; then
    gow_log "Waiting for X Server $DISPLAY to be available"
    /opt/gow/wait-x11
fi

exec /opt/gow/startup-app.sh