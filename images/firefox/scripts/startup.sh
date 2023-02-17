#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Firefox"

exec /usr/bin/firefox
