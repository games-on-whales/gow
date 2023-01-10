#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Waiting for X Server $DISPLAY to be available"
/opt/gow/wait-x11

LOG_LEVEL=${LOG_LEVEL:-INFO}
gow_log "Starting sunshine with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

mkdir -p "$HOME/.config/sunshine/"
cp -n /cfg/sunshine.conf "$HOME/.config/sunshine/sunshine.conf"
cp -n /cfg/sunshine.conf "$HOME/.config/sunshine/sunshine.conf.sample"
cp -n /cfg/apps.json "$HOME/.config/sunshine/apps.json"

## Pass sunshine credentials via ENV
sunshine "${HOME}/.config/sunshine/sunshine.conf" --creds "${SUNSHINE_USER:-admin}" "${SUNSHINE_PASS:-admin}"

# Start Sunshine
exec sunshine min_log_level="$LOG_LEVEL" "${HOME}/.config/sunshine/sunshine.conf"
