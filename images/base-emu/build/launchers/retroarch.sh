#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting RetroArch DISPLAY=${DISPLAY} args: $*"
if [[ $# -eq 0 ]]; then
    exec retroarch --fullscreen
fi

exec retroarch --fullscreen "$@"
