#!/bin/bash
set -e 

function LOG {
    echo $(date -R): $0: $*
}

if [ -z "$DISPLAY" ]; then
    LOG "FATAL: No DISPLAY environment variable set.  No X."
    exit 13
fi

LOG "Waiting for X Server $DISPLAY to be available"

# Taken from https://gist.github.com/tullmann/476cc71169295d5c3fe6
MAX=120 # About 120 seconds
CT=0
while ! xdpyinfo >/dev/null 2>&1; do
    sleep 1s
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        LOG "FATAL: $0: Gave up waiting for X server $DISPLAY"
        exit 11
    fi
done

LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG "Starting sunshine with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

mkdir -p $HOME/sunshine/
cp -u /cfg/sunshine.conf $HOME/sunshine/sunshine.conf
cp -u /cfg/apps.json $HOME/sunshine/apps.json

# Start Sunshine
sunshine \
  min_log_level=$LOG_LEVEL \
  ${HOME}/sunshine/sunshine.conf