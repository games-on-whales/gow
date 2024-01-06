#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Symlinking Bioses from /Bioses"
ln -sf /bioses $HOME

#########################################
# Configure Pegasus
#########################################
PEGASUS_CFG=$HOME/.config/pegasus-frontend
gow_log "Pegasus - Configure"
mkdir -p "$PEGASUS_CFG"
gow_log "Pegasus - Copying game_dirs.txt, if not edited"
cp -u /cfg/app/game_dirs.txt "${PEGASUS_CFG}/game_dirs.txt"

#########################################
# Configure PCSX2
#########################################
PCSX2_CFG=$HOME/.config/PCSX2

gow_log "PCSX2 - Configure"
mkdir -p "$PCSX2_CFG/inis/"
cp -u /cfg/PCSX2/PCSX2.ini "${PCSX2_CFG}/inis/PCSX2.ini"

#########################################
# Configure Dolphin
#########################################
DOLPHIN_CFG=$HOME/.config/dolphin-emu

mkdir -p "$DOLPHIN_CFG"
gow_log "Dolphin - Copying config, if not edited"
cp -u /cfg/dolphin/Dolphin.ini "$DOLPHIN_CFG/Dolphin.ini"

#########################################
# Configure Retroarch
#########################################
RETROARCH_CFG_DIR=$HOME/.config/retroarch

# Copying config in case it's the first time we mount from the host
gow_log "Retroarch - Copying config, if not edited"
mkdir -p "$RETROARCH_CFG_DIR/cores/"
cp -u /cfg/retroarch/retroarch.cfg "$RETROARCH_CFG_DIR/retroarch.cfg"

gow_log "Retroarch - Checking RA Assets presence, if none - install them"
if [ ! -d "$RETROARCH_CFG_DIR/assets" ]; then
    gow_log "Retroarch - No assets found, starting install"
    wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$RETROARCH_CFG_DIR/assets"
    rm /tmp/assets.zip
fi

# Copy pre-installed cores from the retroarch ppa
# shellcheck disable=SC2046
# cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$CFG_DIR/cores/"

#########################################
# Configure Yuzu
#########################################
YUZU_CFG_DIR=$HOME/.local/share/yuzu

gow_log "YUZU - Copying pred/title keys for YUZU"
if test -f /bioses/prod.keys; then
    gow_log "YUZU - /bioses/prod.keys present, copy to YUZU folder"
	  mkdir -p $YUZU_CFG_DIR/keys/
    cp -u $HOME/bioses/prod.keys $YUZU_CFG_DIR/keys/prod.keys
fi
if test -f /bioses/prod.keys; then
    gow_log "YUZU - /bioses/title.keys present, copy to YUZU folder"
	  mkdir -p $YUZU_CFG_DIR/keys/
    cp -u $HOME/bioses/title.keys $YUZU_CFG_DIR/keys/title.keys
fi

#########################################
# Configure CEMU
#########################################
CEMU_CFG_DIR=$HOME/.config/Cemu

gow_log "CEMU - Setting default sound device and run in fullscreen, if not edited"
cp /cfg/cemu/settings.xml /cfg/cemu/settings_new.xml
searchString="<TVDevice>replace_me</TVDevice>"
replaceString="<TVDevice>${PULSE_SINK}</TVDevice>"
sed -i -e "s|$searchString|$replaceString|g" /cfg/cemu/settings_new.xml
searchString="<PadDevice>replace_me</PadDevice>"
replaceString="<PadDevice>${PULSE_SINK}</PadDevice>"
sed -i -e "s|$searchString|$replaceString|g" /cfg/cemu/settings_new.xml
# Set the date of the file back to the original date
touch -r /cfg/cemu/settings.xml /cfg/cemu/settings_new.xml
cp -u /cfg/cemu/settings_new.xml $CEMU_CFG_DIR/settings.xml

#########################################
# Configure RPCS3
#########################################
RPCS3_CFG_DIR=$HOME/.config/rpcs3

gow_log "RPCS3 - Copying custom config (disable Auto-Update pop-up), if not edited"
mkdir -p $RPCS3_CFG_DIR/GuiConfigs/
cp -u /cfg/rpcs3/CurrentSettings.ini $RPCS3_CFG_DIR/GuiConfigs/CurrentSettings.ini

gow_log "RPCS3 - Setting default sound device and run in fullscreen, if not edited"
mkdir -p $RPCS3_CFG_DIR/
cp /cfg/rpcs3/config.yml /cfg/rpcs3/config_new.yml
searchString="Audio Device: \"@@@default@@@\""
replaceString="Audio Device: \"${PULSE_SINK}\""
sed -i -e "s|$searchString|$replaceString|g" /cfg/rpcs3/config_new.yml
# Set the date of the file back to the original date
touch -r /cfg/rpcs3/config.yml /cfg/rpcs3/config_new.yml
cp -u /cfg/rpcs3/config_new.yml $RPCS3_CFG_DIR/config.yml

#########################################
# Configure XEMU
#########################################
XEMU_CFG_DIR=$HOME/.local/share/xemu
gow_log "XEMU - Copying custom config - settings, if not edited"
mkdir -p $XEMU_CFG_DIR/xemu/
cp -u /cfg/xemu/xemu.toml $XEMU_CFG_DIR/xemu/xemu.toml
gow_log "XEMU - Copying basic hard drive (/bioses/xbox_hdd.gcow2), if present and not edited"
if [ -f "/bioses/xbox_hdd.qcow2" ]; then
    cp -u /bioses/xbox_hdd.qcow2 $XEMU_CFG_DIR/xemu/xbox_hdd.qcow2
fi

if [ -n "$RUN_GAMESCOPE" ]; then
  echo "Gamescope - Starting Pegasus"
  export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  export GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- pegasus-fe
else
  echo "Sway - Starting Pegasus"
  export XDG_SESSION_TYPE=wayland
  mkdir -p $HOME/.config/sway/
  cp /cfg/sway/config $HOME/.config/sway/config
  exec sway --unsupported-gpu
fi
