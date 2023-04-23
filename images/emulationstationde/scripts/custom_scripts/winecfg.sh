#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting Winecfg with DISPLAY=${DISPLAY}"
winecfg