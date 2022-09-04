#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Waiting for X Server $DISPLAY to be available"
/opt/gow/wait-x11

LOG_LEVEL=${LOG_LEVEL:-INFO}
gow_log "Starting sunshine with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

mkdir -p "$HOME/sunshine/"
cp -u /cfg/sunshine.conf "$HOME/sunshine/sunshine.conf"
cp -u /cfg/apps.json "$HOME/sunshine/apps.json"

## Pass sunshine credentials via ENV
sudo -u "$(whoami)" -E sunshine "${HOME}/sunshine/sunshine.conf" --creds "${SUNSHINE_USER:-admin}" "${SUNSHINE_PASS:-admin}"

# Start Sunshine
exec sudo -u "$(whoami)" -E sunshine min_log_level="$LOG_LEVEL" "${HOME}/sunshine/sunshine.conf"
