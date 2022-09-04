#!/bin/bash

set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Waiting for X Server $DISPLAY to be available"
/opt/gow/wait-x11

# Launch the container's startup script
exec /opt/gow/startup-x11.sh
