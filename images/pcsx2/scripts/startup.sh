#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting PCSX2"

CFG_DIR=$HOME/.config/PCSX2

exec /usr/bin/pcsx2-qt

