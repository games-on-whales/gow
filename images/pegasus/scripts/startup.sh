#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh
source /opt/gow/launch-comp.sh

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
# Configure CEMU
#########################################
CEMU_CFG_DIR=$HOME/.config/Cemu
mkdir -p ${CEMU_CFG_DIR}/

gow_log "CEMU - Setting default sound device and run in fullscreen, if not edited"
if ! test -f $CEMU_CFG_DIR/settings.xml; then
  gow_log "Pulse sink is: ${PULSE_SINK}"
  cp /cfg/cemu/settings.xml /tmp/settings_new.xml
  searchString="<TVDevice>replace_me</TVDevice>"
  replaceString="<TVDevice>${PULSE_SINK}</TVDevice>"
  sed -i -e "s|$searchString|$replaceString|g" /tmp/settings_new.xml
  searchString="<PadDevice>replace_me</PadDevice>"
  replaceString="<PadDevice>${PULSE_SINK}</PadDevice>"
  sed -i -e "s|$searchString|$replaceString|g" /tmp/settings_new.xml
  cp /tmp/settings_new.xml $CEMU_CFG_DIR/settings.xml
fi

#########################################
# Configure RPCS3
#########################################
RPCS3_CFG_DIR=$HOME/.config/rpcs3

gow_log "RPCS3 - Copying custom config (disable Auto-Update pop-up), if not edited"
mkdir -p $RPCS3_CFG_DIR/GuiConfigs/
cp -u /cfg/rpcs3/CurrentSettings.ini $RPCS3_CFG_DIR/GuiConfigs/CurrentSettings.ini

gow_log "RPCS3 - Setting default sound device and run in fullscreen, if not edited"
mkdir -p $RPCS3_CFG_DIR/
if ! test -f $RPCS3_CFG_DIR/config.yml; then
  echo "File does not exist."
  cp /cfg/rpcs3/config.yml /tmp/config_new.yml
  searchString="Audio Device: \"@@@default@@@\""
  replaceString="Audio Device: \"${PULSE_SINK}\""
  sed -i -e "s|$searchString|$replaceString|g" /tmp/config_new.yml
  # Set the date of the file back to the original date
  cp /tmp/config_new.yml $RPCS3_CFG_DIR/config.yml
fi

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

# Launch the app
launcher pegasus-fe
