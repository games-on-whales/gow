#!/bin/bash
set -e 

LOG_LEVEL=${LOG_LEVEL:-INFO}
echo "Starting sunshine with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

# Copying config in case it's the first time we mount from the host
mkdir -p $HOME/retroarch/
cp -u /cfg/retroarch.cfg $HOME/retroarch/retroarch.cfg

mkdir -p $HOME/sunshine/
cp -u /cfg/sunshine.conf $HOME/sunshine/sunshine.conf
cp -u /cfg/apps.json $HOME/sunshine/apps.json

# Start Sunshine
/sunshine/sunshine \
  min_log_level=$LOG_LEVEL \
  ${HOME}/sunshine/sunshine.conf