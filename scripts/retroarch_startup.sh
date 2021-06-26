#!/bin/bash
set -e 

LOG_LEVEL=${LOG_LEVEL:-INFO}
echo "Starting RetroArch with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

# Copying config in case it's the first time we mount from the host
mkdir -p $HOME/retroarch/
cp -u /cfg/retroarch.cfg $HOME/retroarch/retroarch.cfg

# Start Sunshine
/usr/bin/retroarch --config /home/retro/retroarch/retroarch.cfg