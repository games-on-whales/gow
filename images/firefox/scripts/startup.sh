#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Firefox"

if [ -z "$RUN_GAMESCOPE" ]; then
  exec /usr/bin/firefox
else
   /usr/games/gamescope -b -- /usr/bin/firefox
fi