#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

#########################################
# Configure PCSX2
#########################################
gow_log "Configure PCSX2"
PCSX2_CFG=$HOME/.config/PCSX2
mkdir -p "$PCSX2_CFG"
cp -u /cfg/PCSX2/PCSX2.ini "${PCSX2_CFG}/inis/PCSX2.ini"

#########################################
# Configure Dolphin
#########################################
gow_log "Configure Dolphin"
DOLPHIN_CFG=$HOME/.config/dolphin-emu
mkdir -p "$DOLPHIN_CFG"
cp -u /cfg/dolphin/GCPadNew.ini "$DOLPHIN_CFG/GCPadNew.ini"
cp -u /cfg/dolphin/Dolphin.ini "$DOLPHIN_CFG/Dolphin.ini"

#########################################
# Configure Retroarch
#########################################
gow_log "Configure Retroarch"
CFG_DIR=$HOME/.config/retroarch

# Copying config in case it's the first time we mount from the host
mkdir -p "$CFG_DIR/cores/"

cp -u /cfg/retroarch/retroarch.cfg "$CFG_DIR/retroarch.cfg"

# Copy pre-installed cores from the retroarch ppa
# shellcheck disable=SC2046
# cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$CFG_DIR/cores/"

#########################################
# Configure Yuzu
#########################################
gow_log "Copying keys for YUZU if it is present in bioses or newer"
YUZU_CFG_DIR=$HOME/.local/share/yuzu
YUZU_CFG_DIR2=$HOME/.config/yuzu
if test -f /bioses/prod.keys; then
    gow_log "YUZU keys are present, copy them to YUZU folder"
	mkdir -p $YUZU_CFG_DIR/keys/
    cp -u $HOME/bioses/prod.keys $YUZU_CFG_DIR/keys/prod.keys
fi

gow_log "Copying custom config - YUZU QT settings, if not edited"
mkdir -p $YUZU_CFG_DIR2
cp -u /cfg/yuzu/qt-config.ini $YUZU_CFG_DIR2/qt-config.ini

#########################################
# Configure Xemu
#########################################
gow_log "Configure Xemu"
XEMU_CFG_DIR=$HOME/.local/share/xemu
gow_log "Copying custom config - XEMU settings, if not edited"
mkdir -p $XEMU_CFG_DIR/xemu/
cp -u /cfg/xemu/xemu.toml $XEMU_CFG_DIR/xemu/xemu.toml
if [ -f "/bioses/xbox_hdd.qcow2" ]; then
    cp -u /bioses/xbox_hdd.qcow2 $XEMU_CFG_DIR/xemu/xbox_hdd.qcow2
fi
gow_log "Symlinking Bioses from /Bioses"
ln -sf /bioses $HOME

# if there are no assets, manually download them
if [ ! -d "$CFG_DIR/assets" ]; then
    wget -q --show-progress -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$CFG_DIR/assets"
    rm /tmp/assets.zip
fi

if [ -n "$RUN_GAMESCOPE" ]; then
  export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  export GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- pegasus-fe
else
 exec pegasus-fe
fi
