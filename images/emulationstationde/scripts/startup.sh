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

gow_log "Copying custom gamelist - ES-DE Custom Scripts Platform, if not edited"
mkdir -p $ES_CFG_DIR/gamelists/Custom\ Scripts
chown ${UNAME}:${UNAME} $ES_CFG_DIR/gamelists/Custom\ Scripts
cp -u /cfg/es/gamelist.xml $ES_CFG_DIR/gamelists/Custom\ Scripts

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

gow_log "Copying hdd for XEMU if it is present in bioses or newer"
if test -f $HOME/bioses/xbox_hdd.qcow2; then
    gow_log "XEMU hdd is present, copy it to XEMU folder"
	mkdir -p $XEMU_CFG_DIR/xemu/
    cp -u $HOME/bioses/xbox_hdd.qcow2 $XEMU_CFG_DIR/xemu/xbox_hdd.qcow2
fi

gow_log "Copying keys for YUZU if it is present in bioses or newer"
if test -f $HOME/bioses/prod.keys; then
    gow_log "YUZU keys are present, copy them to YUZU folder"
	mkdir -p $YUZU_CFG_DIR/keys/
    cp -u $HOME/bioses/prod.keys $YUZU_CFG_DIR/keys/prod.keys
fi

gow_log "Copying custom config - YUZU QT settings, if not edited"
mkdir -p $YUZU_CFG_DIR2
cp -u /cfg/yuzu/qt-config.ini $YUZU_CFG_DIR2/qt-config.ini

gow_log "Copying default config - EmulationStation settings, if not edited"
mkdir -p $ES_CFG_DIR
cp -u /cfg/es/es_settings.xml $ES_CFG_DIR/es_settings.xml

gow_log "Change media directory for EmulationStation to /media"
sed -i 's/<string name="MediaDirectory" value="" \/>/<string name="MediaDirectory" value="\/media" \/>/g' $ES_CFG_DIR/es_settings.xml

gow_log "Change ROMs directory for EmulationStation to /ROMs"
sed -i 's/<string name="ROMDirectory" value="" \/>/<string name="ROMDirectory" value="\/ROMs" \/>/g' $ES_CFG_DIR/es_settings.xml

gow_log "Copying custom launch scripts for emulators and programs, if not edited"
mkdir -p $ES_CFG_DIR/custom_scripts
chown ${UNAME}:${UNAME} $ES_CFG_DIR/custom_scripts
cp -ur /cfg/custom_scripts/ $ES_CFG_DIR

gow_log "Checking RA Assets presence, if none - install them"
if [ ! -d "$RA_CFG_DIR/assets" ]; then
    gow_log "No assets found, starting install"
    wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$RA_CFG_DIR/assets"
    rm /tmp/assets.zip
fi

gow_log "Symlinking AppImage Emulators from /Applications"
ln -sf /Applications $HOME

gow_log "Symlinking Bioses from /Bioses"
ln -sf /bioses $HOME

# gow_log "Starting up Gamescope"
# chown ${UNAME}:${UNAME} /usr/games/gamescope

if [ -n "$RUN_GAMESCOPE" ]; then
  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope ${GAMESCOPE_MODE} -W ${GAMESCOPE_WIDTH} -H ${GAMESCOPE_HEIGHT} -r ${GAMESCOPE_REFRESH} -- /opt/gow/startup-es.sh
else
 exec /usr/bin/emulationstation
fi