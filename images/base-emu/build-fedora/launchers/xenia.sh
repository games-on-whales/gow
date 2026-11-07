#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

XENIA_WORKDIR="$HOME/.local/share/Xenia/root"
mkdir -p "$XENIA_WORKDIR"

gow_log "Starting Xenia Canary with DISPLAY=${DISPLAY} and working directory $XENIA_WORKDIR and args: $@"
cd "$XENIA_WORKDIR"
/Applications/xenia-canary/xenia_canary "$@"