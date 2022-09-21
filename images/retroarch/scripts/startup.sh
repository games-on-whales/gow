#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting RetroArch"

# Copying config in case it's the first time we mount from the host
mkdir -p "$HOME/retroarch/libretro/"
cp -u /cfg/retroarch.cfg "$HOME/retroarch/retroarch.cfg"
# Copy pre-installed cores from the retroarch ppa
cp -u /usr/lib/x86_64-linux-gnu/libretro/* /home/retro/retroarch/libretro/

exec /usr/bin/retroarch \
    --config "${HOME}/retroarch/retroarch.cfg"
