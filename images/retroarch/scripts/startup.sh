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
LOG "Starting RetroArch with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

# Copying config in case it's the first time we mount from the host
mkdir -p $HOME/retroarch/
cp -u /cfg/retroarch.cfg $HOME/retroarch/retroarch.cfg

# Start Sunshine
/usr/bin/retroarch --config /home/retro/retroarch/retroarch.cfg #--verbose