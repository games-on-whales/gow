#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

PERSIST_DIR="/home/retro-persist"
AGENT_EXE_LINUX="$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent/Agent.exe"

if [ ! -f "$AGENT_EXE_LINUX" ]; then
    gow_log "First run: copying Battle.net prefix to persistent storage..."
    cp -a /opt/battlenet/. "$PERSIST_DIR/"
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

# Create wrapper with all env vars inside
cat > /tmp/launch-bnet.sh << 'LAUNCH'
#!/bin/bash
export WINEPREFIX="/home/retro-persist"
export WINEDLLOVERRIDES="mscoree,mshtml=,wintrust=n,winedbg=d"
export WINE_SIMULATE_WRITECOPY=1
export WINEFSYNC=1

PERSIST_DIR="/home/retro-persist"
AGENT_VERSIONED=$(find "$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent" -name "Agent.exe" -path "*/Agent.*/Agent.exe" | head -1)
AGENT_VERSIONED_WIN=$(echo "$AGENT_VERSIONED" | sed "s|${PERSIST_DIR}/drive_c|C:|" | sed 's|/|\\|g')

wine "$AGENT_VERSIONED_WIN" --locale=enGB --region=EU --no-sandbox &
sleep 3
exec wine "C:\\Program Files (x86)\\Battle.net\\Battle.net.exe" --disable-gpu --disable-gpu-compositing --locale=enGB --region=EU --no-sandbox
LAUNCH
chmod +x /tmp/launch-bnet.sh

source /opt/gow/launch-comp.sh
launcher /tmp/launch-bnet.sh
