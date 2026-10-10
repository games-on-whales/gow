#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

PERSIST_DIR="/home/retro-persist"
AGENT_EXE_LINUX="$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent/Agent.exe"

if [ ! -f "$AGENT_EXE_LINUX" ]; then
    gow_log "First run: copying Battle.net prefix to persistent storage..."
    cp -a --no-preserve=ownership /opt/battlenet/. "$PERSIST_DIR/"
    gow_log "Copy complete."
fi

rm -f "$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent/Agent.dat"

# Custom Sway rules for Battle.net
mkdir -p "$HOME/.config/sway"
cat > "$HOME/.config/sway/custom-cfg" << 'SWAYCFG'
for_window [class=".*"] floating enable
for_window [class="explorer.exe"] move scratchpad
SWAYCFG

# Minimal waybar with just a quit button
mkdir -p "$HOME/.config/waybar"
cat > "$HOME/.config/waybar/config" << 'WAYBAR'
{
    "layer": "top",
    "position": "top",
    "height": 24,
    "modules-right": ["custom/quit"],
    "custom/quit": {
        "format": "✕ Close",
        "on-click": "swaymsg exit",
        "tooltip": false
    }
}
WAYBAR
cat > "$HOME/.config/waybar/style.css" << 'WAYCSS'
* { font-size: 13px; font-family: sans-serif; }
window#waybar { background: rgba(0,0,0,0.7); color: #ffffff; }
#custom-quit { padding: 0 10px; color: #ff5555; }
#custom-quit:hover { background: #ff5555; color: #ffffff; }
WAYCSS

# Create wrapper with all env vars inside. Battle.net runs through umu-run (Proton-GE in the
# Steam Linux Runtime), the same way Lutris runs it. Proton-GE and the runtime are baked in the image.
cat > /tmp/launch-bnet.sh << 'LAUNCH'
#!/bin/bash
PERSIST_DIR="/home/retro-persist"
export XDG_DATA_HOME=/opt/umu-data
export PROTONPATH="$XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton"
export UMU_RUNTIME_UPDATE=0
export WINEPREFIX="$PERSIST_DIR"
export GAMEID=0
export WINEDLLOVERRIDES="locationapi=d"
export STAGING_SHARED_MEMORY=1
export DXVK_STATE_CACHE_PATH="$PERSIST_DIR"
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$PERSIST_DIR"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# Optional overrides/debugging (e.g. export PROTON_LOG=1 PROTON_LOG_DIR=/home/retro-persist)
[ -f "$PERSIST_DIR/bnet.env" ] && . "$PERSIST_DIR/bnet.env"

exec umu-run "$PERSIST_DIR/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
LAUNCH
chmod +x /tmp/launch-bnet.sh

source /opt/gow/launch-comp.sh
launcher /tmp/launch-bnet.sh
