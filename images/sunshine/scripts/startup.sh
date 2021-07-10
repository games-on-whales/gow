#!/bin/bash
set -e 

function LOG {
    echo $(date -R): $0: $*
}

LOG "Waiting for X Server $DISPLAY to be available"
wait-x11

LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG "Starting sunshine with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

mkdir -p $HOME/sunshine/
cp -u /cfg/sunshine.conf $HOME/sunshine/sunshine.conf
cp -u /cfg/apps.json $HOME/sunshine/apps.json

## Pass sunshine credentials via ENV
sudo -u $(whoami) -E sunshine ${HOME}/sunshine/sunshine.conf --creds ${SUNSHINE_USER:-admin} ${SUNSHINE_PASS:-admin}

# Start Sunshine
sudo -u $(whoami) -E sunshine \
  min_log_level=$LOG_LEVEL \
  ${HOME}/sunshine/sunshine.conf
