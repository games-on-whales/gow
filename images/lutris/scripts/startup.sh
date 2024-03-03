#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Lutris with DISPLAY=${DISPLAY}"

# Start Steam. Use `sudo` to make sure that group membership gets reloaded
exec /usr/games/lutris
