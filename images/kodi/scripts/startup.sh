#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Kodi"

source /opt/gow/launch-comp.sh
launcher kodi
