#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Configure Dolphin"
DOLPHIN_CFG=$HOME/.config/dolphin-emu
mkdir -p "$DOLPHIN_CFG"
cp -u /cfg/dolphin/GCPadNew.ini "$DOLPHIN_CFG/GCPadNew.ini"

gow_log "Configure Retroarch"

CFG_DIR=$HOME/.config/retroarch

# Copying config in case it's the first time we mount from the host
mkdir -p "$CFG_DIR/cores/"

cp -u /cfg/retroarch.cfg "$CFG_DIR/retroarch.cfg"

# Copy pre-installed cores from the retroarch ppa
# shellcheck disable=SC2046
# cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$CFG_DIR/cores/"

# if there are no assets, manually download them
if [ ! -d "$CFG_DIR/assets" ]; then
    wget -q --show-progress -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$CFG_DIR/assets"
    rm /tmp/assets.zip
fi

if [ -n "$RUN_GAMESCOPE" ]; then
  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- pegasus-fe
else
 exec pegasus-fe
fi
