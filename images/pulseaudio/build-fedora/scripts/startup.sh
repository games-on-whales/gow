#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Removing all files from $HOME/.config/pulse"

mkdir -p "$HOME/.config/pulse"
rm -rf "$HOME/.config/pulse/*"

gow_log "Starting pulseaudio"
exec pulseaudio --log-level=1 #--log-target=stderr -v
