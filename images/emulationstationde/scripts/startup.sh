#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Application"

RA_CFG_DIR=$HOME/.config/retroarch
RPCS3_CFG_DIR=$HOME/.config/rpcs3
YUZU_CFG_DIR=$HOME/.local/share/yuzu
XEMU_CFG_DIR=$HOME/.local/share/xemu
PCSX2_CFG_DIR=$HOME/.config/PCSX2
ES_CFG_DIR=$HOME/.emulationstation

# Copying config in case it's the first time we mount from the host
mkdir -p "$RA_CFG_DIR/cores/"

gow_log "Copying custom config - retroarch.cfg, if not edited"
cp -u /cfg/retroarch.cfg "$RA_CFG_DIR/retroarch.cfg"

gow_log "Copying custom config - ES-DE Custom Scripts Platform, if not edited"
mkdir -p /home/retro/.emulationstation/custom_systems
chown ${UNAME}:${UNAME} /home/retro/.emulationstation/custom_systems
cp -u /cfg/es_systems.xml /home/retro/.emulationstation/custom_systems

gow_log "Copying custom config - RPCS3 Controller Bindings for Wolf, if not edited"
cp -u /cfg/rpcs3/Default.yml /home/retro/.config/rpcs3/input_configs/global/Default.yml

gow_log "Copying custom config - PCSX2 settings, if not edited"
cp -u /cfg/pcsx2/PCSX2.ini /home/retro/.config/PCSX2/inis/PCSX2.ini

gow_log "Copying custom config - XEMU settings, if not edited"
cp -u /cfg/xemu/xemu.toml /home/retro/.local/share/xemu/xemu/xemu.toml

gow_log "Copying keys for YUZU if they are present or newer"
if test -f $HOME/bioses/prod.keys; then
    gow_log "YUZU keys are present, copy them to YUZU folder"
    cp -u $HOME/bioses/prod.keys $YUZU_CFG_DIR/keys/prod.keys
fi

gow_log "Copying custom launch scripts for emulators"
mkdir -p /home/retro/.emulationstation/custom_scripts
chown ${UNAME}:${UNAME} /home/retro/.emulationstation/custom_scripts
cp -u /cfg/retroarch.sh /home/retro/.emulationstation/custom_scripts/Launch_Retroarch.sh
cp -u /cfg/rpcs3.sh /home/retro/.emulationstation/custom_scripts/Launch_rpcs3.sh
cp -u /cfg/!Install_RPCS3_Firmware.sh /home/retro/.emulationstation/custom_scripts/!Install_RPCS3_Firmware.sh
cp -u /cfg/yuzu.sh /home/retro/.emulationstation/custom_scripts/Launch_yuzu.sh
cp -u /cfg/pcsx2.sh /home/retro/.emulationstation/custom_scripts/Launch_pcsx2.sh
cp -u /cfg/xemu.sh /home/retro/.emulationstation/custom_scripts/Launch_xemu.sh

# if there are no cores, copy from the retroarch ppa
# shellcheck disable=SC2046
cp -u /usr/lib/$(uname -m)-linux-gnu/libretro/* "$RA_CFG_DIR/cores/"

# if there are no assets, manually download them
if [ ! -d "$RA_CFG_DIR/assets" ]; then
    wget -q --show-progress -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    7z x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$RA_CFG_DIR/assets"
    rm /tmp/assets.zip
fi

gow_log "Installing AppImage Emulators"
mkdir -p /home/retro/Applications
chown ${UNAME}:${UNAME} /home/retro/Applications
cp -u /tmp/yuzu-emu.AppImage /home/retro/Applications/yuzu-emu.AppImage
chmod a+x /home/retro/Applications/yuzu-emu.AppImage	
cp -u /tmp/rpcs3-emu.AppImage /home/retro/Applications/rpcs3-emu.AppImage
chmod a+x /home/retro/Applications/rpcs3-emu.AppImage

gow_log "777 permissions on necessary folder"
mkdir -p /home/retro/.local/share/yuzu/keys/
chmod 777 /home/retro/.local/share/yuzu/keys/

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