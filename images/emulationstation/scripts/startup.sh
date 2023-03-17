#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting EmulationStation-DE"

CFG_DIR=$HOME/.config/es

# Copying config in case it's the first time we mount from the host
mkdir -p "$CFG_DIR/cores/"

cp -u /cfg/retroarch.cfg "$CFG_DIR/retroarch.cfg"

# Copy pre-installed cores from the retroarch ppa
# shellcheck disable=SC2046
cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$CFG_DIR/cores/"

# if there are no assets, manually download them
if [ ! -d "$CFG_DIR/assets" ]; then
    wget -q --show-progress -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$CFG_DIR/assets"
    rm /tmp/assets.zip
fi

exec /usr/bin/emulationstation
