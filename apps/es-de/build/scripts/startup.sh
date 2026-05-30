#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Application preparation"

# Host bind mounts from Wolf config.toml land at /ROMs, /bioses, /media.
gow_log "Library symlinks for emulator configs"
ln -sf /ROMs "${HOME}/ROMs" 2>/dev/null || true
ln -sf /bioses "${HOME}/bioses" 2>/dev/null || true

if [[ -d /ROMs ]] && [[ -z "$(ls -A /ROMs 2>/dev/null)" ]]; then
    gow_log "WARN: /ROMs is empty — set ROMs library in the plugin and run Fix mounts, then relaunch ES-DE"
fi

RA_CFG_DIR=$HOME/.config/retroarch
RPCS3_CFG_DIR=$HOME/.config/rpcs3
XEMU_CFG_DIR=$HOME/.local/share/xemu
PCSX2_CFG_DIR=$HOME/.config/PCSX2
ES_CFG_DIR=$HOME/ES-DE
ROMS_DIR=/ROMs

gow_log "Seeding profile launchers from image (ROM-aware scripts)"
mkdir -p "${HOME}/Applications/launchers"
cp -fu /Applications/launchers/*.sh "${HOME}/Applications/launchers/" 2>/dev/null || true
chmod -R a+x "${HOME}/Applications/launchers" 2>/dev/null || true

gow_log "Copying custom config - retroarch.cfg, if not edited"
mkdir -p "$RA_CFG_DIR/cores/"
cp -u /cfg/retroarch/retroarch.cfg "$RA_CFG_DIR/retroarch.cfg"

gow_log "Generating ES-DE systems (Custom Scripts + /ROMs platforms)"
mkdir -p "$ES_CFG_DIR/custom_systems"
# shellcheck source=/opt/gow/rom-config/gow_refresh_rom_library.sh
source /opt/gow/rom-config/gow_refresh_rom_library.sh
gow_generate_esde_systems "$ES_CFG_DIR/custom_systems/es_systems.xml"

gow_log "Refreshing ES-DE Custom Scripts launcher gamelist (keeps existing entries)"
mkdir -p "$ES_CFG_DIR/gamelists/Custom Scripts"
if [[ ! -f "$ES_CFG_DIR/gamelists/Custom Scripts/gamelist.xml" ]]; then
    cp /cfg/es/gamelist.xml "$ES_CFG_DIR/gamelists/Custom Scripts/gamelist.xml"
fi
gow_refresh_esde_custom_scripts_gamelist "$ES_CFG_DIR/gamelists/Custom Scripts/gamelist.xml"

gow_log "Copying custom config - RPCS3 Controller Bindings for Wolf and disable Auto-Update pop-up, if not edited"
mkdir -p $RPCS3_CFG_DIR/input_configs/global/
cp -u /cfg/rpcs3/Default.yml $RPCS3_CFG_DIR/input_configs/global/Default.yml
mkdir -p $RPCS3_CFG_DIR/GuiConfigs
cp -u /cfg/rpcs3/CurrentSettings.ini $RPCS3_CFG_DIR/GuiConfigs/CurrentSettings.ini

gow_log "Copying custom config - PCSX2 settings, if not edited"
mkdir -p $PCSX2_CFG_DIR/inis/
cp -u /cfg/pcsx2/PCSX2.ini $PCSX2_CFG_DIR/inis/PCSX2.ini

gow_log "Copying custom config - Dolphin settings and Wolf gamepad profiles, if not edited"
mkdir -p "$HOME/.config/dolphin-emu/Profiles/GCPad" "$HOME/.config/dolphin-emu/Profiles/Wiimote"
cp -u /cfg/dolphin/Dolphin.ini "$HOME/.config/dolphin-emu/Dolphin.ini" 2>/dev/null || true
cp -fu /cfg/dolphin/Profiles/GCPad/*.ini "$HOME/.config/dolphin-emu/Profiles/GCPad/" 2>/dev/null || true
cp -fu /cfg/dolphin/Profiles/Wiimote/*.ini "$HOME/.config/dolphin-emu/Profiles/Wiimote/" 2>/dev/null || true

gow_log "Copying custom config - XEMU settings, if not edited"
mkdir -p $XEMU_CFG_DIR/xemu/
cp -u /cfg/xemu/xemu.toml $XEMU_CFG_DIR/xemu/xemu.toml

gow_log "Copying hdd for XEMU if it is present in bioses or newer"
if test -f $HOME/bioses/xbox_hdd.qcow2; then
    gow_log "XEMU hdd is present, copy it to XEMU folder"
	mkdir -p $XEMU_CFG_DIR/xemu/
    cp -u $HOME/bioses/xbox_hdd.qcow2 $XEMU_CFG_DIR/xemu/xbox_hdd.qcow2
fi

if test -f $ES_CFG_DIR/settings/es_settings.xml; then
    gow_log "EmulationStation settings already exist, checking ROMDirectory"
    if grep -q 'name="ROMDirectory"' "$ES_CFG_DIR/settings/es_settings.xml" \
        && ! grep -q 'name="ROMDirectory" value="/ROMs"' "$ES_CFG_DIR/settings/es_settings.xml"; then
        gow_log "Normalizing ROMDirectory to /ROMs in es_settings.xml"
        sed -i 's/name="ROMDirectory" value="[^"]*"/name="ROMDirectory" value="\/ROMs"/' \
            "$ES_CFG_DIR/settings/es_settings.xml"
    fi
else
  mkdir -p $ES_CFG_DIR/settings/
  cp -u /cfg/es/es_settings.xml $ES_CFG_DIR/settings/es_settings.xml
fi

gow_log "Checking RA Assets presence, if none - install them"
if [ ! -d "$RA_CFG_DIR/assets" ]; then
    gow_log "No assets found, starting install"
    wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/assets.zip
    # Use `7za`, not `7z` -- Fedora's `p7zip` ships only 7za; the `7z`
    # alias requires `p7zip-plugins`. Ubuntu's `p7zip-full` provides both,
    # so 7za works on either base and keeps the script portable.
    7za x /tmp/assets.zip -bso0 -bse0 -bsp1 -o"$RA_CFG_DIR/assets"
    rm /tmp/assets.zip
fi

gow_log "Checking RetroArch joypad autoconfig (required for Wolf virtual controllers)"
if [ ! -d "$RA_CFG_DIR/autoconfig/udev" ] || [ "$(find "$RA_CFG_DIR/autoconfig/udev" -name '*.cfg' 2>/dev/null | wc -l)" -lt 100 ]; then
    gow_log "Downloading libretro autoconfig database"
    wget -q -P /tmp https://buildbot.libretro.com/assets/frontend/autoconfig.zip
    7za x /tmp/autoconfig.zip -bso0 -bse0 -bsp1 -o"$RA_CFG_DIR/autoconfig"
    rm /tmp/autoconfig.zip
fi
if [ -d /cfg/retroarch/autoconfig/udev ]; then
    cp -fu /cfg/retroarch/autoconfig/udev/Wolf_*.cfg "$RA_CFG_DIR/autoconfig/udev/" 2>/dev/null || true
fi
for _ra_key in \
    'input_autodetect_enable = "true"' \
    'input_joypad_driver = "udev"' \
    'input_auto_game_focus = "true"'; do
    _ra_name="${_ra_key%% =*}"
    grep -q "^${_ra_name}" "$RA_CFG_DIR/retroarch.cfg" || echo "$_ra_key" >> "$RA_CFG_DIR/retroarch.cfg"
done

gow_log "Giving permissions to user"
chown -R ${UNAME}:${UNAME} $ES_CFG_DIR
mkdir -p ${HOME}/.config
chown -R ${UNAME}:${UNAME} ${HOME}/.config
