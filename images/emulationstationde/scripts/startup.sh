#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Application preparation"

RA_CFG_DIR=$HOME/.config/retroarch
RPCS3_CFG_DIR=$HOME/.config/rpcs3
YUZU_CFG_DIR=$HOME/.local/share/yuzu
YUZU_CFG_DIR2=$HOME/.config/yuzu
XEMU_CFG_DIR=$HOME/.local/share/xemu
PCSX2_CFG_DIR=$HOME/.config/PCSX2
ES_CFG_DIR=$HOME/.emulationstation
BIOSES_DIR=$HOME/bioses
ROMS_DIR=$HOME/ROMs
APP_DIR=$HOME/Applications


gow_log "Copying custom config - retroarch.cfg, if not edited"
mkdir -p "$RA_CFG_DIR/cores/"
cp -u /cfg/retroarch/retroarch.cfg "$RA_CFG_DIR/retroarch.cfg"

gow_log "Copying custom config - ES-DE Custom Scripts Platform, if not edited"
mkdir -p $ES_CFG_DIR/custom_systems
chown ${UNAME}:${UNAME} $ES_CFG_DIR/custom_systems
cp -u /cfg/es/es_systems.xml $ES_CFG_DIR/custom_systems

gow_log "Copying custom config - RPCS3 Controller Bindings for Wolf and disable Auto-Update pop-up, if not edited"
mkdir -p $RPCS3_CFG_DIR/input_configs/global/
cp -u /cfg/rpcs3/Default.yml $RPCS3_CFG_DIR/input_configs/global/Default.yml
mkdir -p $RPCS3_CFG_DIR/GuiConfigs
cp -u /cfg/rpcs3/CurrentSettings.ini $RPCS3_CFG_DIR/GuiConfigs/CurrentSettings.ini

gow_log "Copying custom config - PCSX2 settings, if not edited"
mkdir -p $PCSX2_CFG_DIR/inis/
cp -u /cfg/pcsx2/PCSX2.ini $PCSX2_CFG_DIR/inis/PCSX2.ini

gow_log "Copying custom config - XEMU settings, if not edited"
mkdir -p $XEMU_CFG_DIR/xemu/
cp -u /cfg/xemu/xemu.toml $XEMU_CFG_DIR/xemu/xemu.toml

gow_log "Copying keys for YUZU if they are present or newer"
if test -f $HOME/bioses/prod.keys; then
    gow_log "YUZU keys are present, copy them to YUZU folder"
	mkdir -p $YUZU_CFG_DIR/keys/
    cp -u $HOME/bioses/prod.keys $YUZU_CFG_DIR/keys/prod.keys
fi
gow_log "Copying custom config - YUZU QT settings, if not edited"
mkdir -p $YUZU_CFG_DIR2
cp -u /cfg/yuzu/qt-config.ini $YUZU_CFG_DIR2/qt-config.ini


gow_log "Copying custom launch scripts for emulators, if not edited"
mkdir -p $ES_CFG_DIR/custom_scripts
chown ${UNAME}:${UNAME} $ES_CFG_DIR/custom_scripts
cp -u /cfg/custom_scripts/retroarch.sh $ES_CFG_DIR/custom_scripts/Launch_Retroarch.sh
cp -u /cfg/custom_scripts/winecfg.sh $ES_CFG_DIR/custom_scripts/Launch_Winecfg.sh
cp -u /cfg/custom_scripts/rpcs3.sh $ES_CFG_DIR/custom_scripts/Launch_rpcs3.sh
cp -u /cfg/custom_scripts/!Install_RPCS3_Firmware.sh $ES_CFG_DIR/custom_scripts/!Install_RPCS3_Firmware.sh
cp -u /cfg/custom_scripts/yuzu.sh $ES_CFG_DIR/custom_scripts/Launch_yuzu.sh
cp -u /cfg/custom_scripts/pcsx2.sh $ES_CFG_DIR/custom_scripts/Launch_pcsx2.sh
cp -u /cfg/custom_scripts/xemu.sh $ES_CFG_DIR/custom_scripts/Launch_xemu.sh
cp -u /cfg/custom_scripts/steam.sh $ES_CFG_DIR/custom_scripts/Launch_Steam.sh

gow_log "Checking RA Cores presence, if none - install them from PPA"
cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$RA_CFG_DIR/cores/"

gow_log "Checking RA Assets presence, if none - install them"
if [ ! -d "$RA_CFG_DIR/assets" ]; then
    gow_log "No assets found, starting install"
    wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$RA_CFG_DIR/assets"
    rm /tmp/assets.zip
fi

gow_log "Symlinking AppImage Emulators in /Applications for User"
ln -sf /Applications $HOME

# mkdir -p $HOME/Applications
# chown ${UNAME}:${UNAME} $APP_DIR
# cp -u /tmp/yuzu-emu.AppImage $HOME/Applications/yuzu-emu.AppImage
# chmod a+x $HOME/Applications/yuzu-emu.AppImage	
# cp -u /tmp/rpcs3-emu.AppImage $HOME/Applications/rpcs3-emu.AppImage
# chmod a+x $HOME/Applications/rpcs3-emu.AppImage

gow_log "Launching with Gamescope"
chown ${UNAME}:${UNAME} /usr/games/gamescope

if [ -n "$RUN_GAMESCOPE" ]; then
  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope ${GAMESCOPE_MODE} -W ${GAMESCOPE_WIDTH} -H ${GAMESCOPE_HEIGHT} -r ${GAMESCOPE_REFRESH} -- /opt/gow/startup-es.sh
else
 exec /usr/bin/emulationstation
fi