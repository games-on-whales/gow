#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

# An explicit mount at /home/retro-persist wins; otherwise the prefix lives inside Wolf's
# per-profile home (/home/retro), so a new profile needs no extra mount.
if mountpoint -q /home/retro-persist 2>/dev/null; then
    PERSIST_DIR="/home/retro-persist"
else
    PERSIST_DIR="$HOME/.bnet"
fi
mkdir -p "$PERSIST_DIR"
AGENT_EXE_LINUX="$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent/Agent.exe"

if [ ! -f "$AGENT_EXE_LINUX" ]; then
    gow_log "First run: copying Battle.net prefix to persistent storage..."
    cp -a --no-preserve=ownership /opt/battlenet/. "$PERSIST_DIR/"
    gow_log "Copy complete."
fi

rm -f "$PERSIST_DIR/drive_c/ProgramData/Battle.net/Agent/Agent.dat"

# Optional shared game library: mount a host directory at /games and it shows up as drive D:
if [ -d /games ]; then
    ln -sfn /games "$PERSIST_DIR/dosdevices/d:"
fi

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
if mountpoint -q /home/retro-persist 2>/dev/null; then
    PERSIST_DIR="/home/retro-persist"
else
    PERSIST_DIR="$HOME/.bnet"
fi
mkdir -p "$PERSIST_DIR"
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

# pressure-vessel copies the Steam runtime on every launch; that is ~5 s on tmpfs but minutes on a
# ZFS/overlay disk. Use /dev/shm when it is big enough (Wolf runs apps with IpcMode host), else the persistent mount.
# /dev/shm is shared by all containers with IpcMode host, so every start gets its own random directory
# (a second container must not touch the copy of one that is still starting or stopping), and
# leftovers of containers that were killed are removed at the next start.
SHM_FREE_KB=$(df -Pk /dev/shm 2>/dev/null | awk 'NR==2{print $4}')
if [ "${SHM_FREE_KB:-0}" -gt 1500000 ]; then
    find /dev/shm -maxdepth 1 -name 'bnet-pv-*' -user "$(id -u)" -mmin +120 -exec rm -rf {} + 2>/dev/null
    PV_DIR=$(mktemp -d /dev/shm/bnet-pv-XXXXXX)
    export PRESSURE_VESSEL_VARIABLE_DIR="$PV_DIR"
    trap 'rm -rf "$PV_DIR"' EXIT
else
    export PRESSURE_VESSEL_VARIABLE_DIR="$PERSIST_DIR/.pv-var"
fi

# pressure-vessel only shares a few host paths with the game; make the optional game library visible
[ -d /games ] && export PRESSURE_VESSEL_FILESYSTEMS_RW="/games"

# Optional overrides/debugging (e.g. export PROTON_LOG=1 PROTON_LOG_DIR=/home/retro-persist)
[ -f "$PERSIST_DIR/bnet.env" ] && . "$PERSIST_DIR/bnet.env"

TRACE="$PERSIST_DIR/session-trace.log"
T0=$(date +%s)
trace() { printf '%s +%ss %s\n' "$(date +%T)" "$(( $(date +%s) - T0 ))" "$*" >> "$TRACE"; }
if [ "${BNET_TRACE:-1}" = "1" ]; then
    [ -f "$TRACE" ] && mv -f "$TRACE" "$TRACE.1"
    trace "wrapper started"
fi

umu-run "$PERSIST_DIR/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe" &
UMU_PID=$!

# Timeline of the session in $PERSIST_DIR/session-trace.log (previous run: session-trace.log.1):
# a line whenever the set of running Windows processes or of windows changes. Disable with BNET_TRACE=0.
if [ "${BNET_TRACE:-1}" = "1" ]; then
    (
        last=""
        while kill -0 "$UMU_PID" 2>/dev/null; do
            procs=$(ps -eo args= 2>/dev/null | grep -E '^[A-Za-z]:[\\/]' | grep -viE '^[a-z]:[\\/]windows[\\/]' \
                | sed -E 's/\.[eE][xX][eE].*/.exe/; s#^.*[\\/]##' | sort | uniq -c | awk '{printf "%s x%s  ", $2, $1}')
            pgrep -x wineserver >/dev/null 2>&1 && procs="${procs}[wineserver]"
            wins=$(SWAYSOCK="${SWAYSOCK:-/run/user/wolf/sway.socket}" swaymsg -t get_tree 2>/dev/null \
                | grep -o '"name": "[^"]*"' | sed 's/"name": //' | grep -vE '^"(root|__i3|__i3_scratch|WL-1|main)"$' | tr '\n' ' ')
            state="procs: ${procs:-none} | windows: ${wins:-none}"
            if [ "$state" != "$last" ]; then trace "$state"; last="$state"; fi
            sleep 2
        done
    ) &
fi

# umu-run only returns when every Wine process in the prefix is gone, so a helper that a game leaves
# behind (crash handler, ...) would keep the session open after Battle.net and the game are closed.
# End the session once the Battle.net client is gone for a while and no game is left running.
# Disable with BNET_AUTO_EXIT=0; BNET_EXIT_GRACE (seconds) and BNET_EXIT_IGNORE (regex of helper
# processes to ignore) can be set in bnet.env.
if [ "${BNET_AUTO_EXIT:-1}" = "1" ]; then
    (
        GRACE="${BNET_EXIT_GRACE:-4}"
        IGNORE="${BNET_EXIT_IGNORE:-Blizzard.*(Error|Crash)|Crash.?Handler}"
        LOG="$PERSIST_DIR/auto-exit.log"
        seen=0; gone=0; logged=0
        while kill -0 "$UMU_PID" 2>/dev/null; do
            sleep 5
            procs=$(ps -eo args= 2>/dev/null)
            if printf '%s\n' "$procs" | grep -F 'Battle.net.exe' | grep -qv -- '--type='; then
                seen=1; gone=0; logged=0
                continue
            fi
            [ "$seen" = 1 ] || continue
            gone=$((gone + 5))
            [ "$gone" -ge "$GRACE" ] || continue
            left=$(printf '%s\n' "$procs" | grep -E '^[A-Za-z]:[\\/]' \
                | grep -viE '^[a-z]:[\\/]windows[\\/]|Battle\.net[\\/]|Battle\.net\.exe|Agent' \
                | grep -viE "$IGNORE" || true)
            if [ -z "$left" ]; then
                echo "$(date '+%F %T') Battle.net client gone for ${gone}s and no game left: ending session" >> "$LOG"
                touch /tmp/bnet-auto-exit
                [ "${BNET_TRACE:-1}" = "1" ] && trace "auto-exit: client gone for ${gone}s, no game left, stopping umu-run"
                kill "$UMU_PID"
                break
            elif [ "$logged" = 0 ]; then
                { echo "$(date '+%F %T') Battle.net client gone, but these processes are still running:"; printf '%s\n' "$left"; } >> "$LOG"
                logged=1
            fi
        done
    ) &
fi

wait "$UMU_PID"
rc=$?
[ "${BNET_TRACE:-1}" = "1" ] && trace "umu-run exited rc=$rc"
# Exit 0 after a requested stop so the compositor wrapper (exec ... && killall sway) ends the session
[ -f /tmp/bnet-auto-exit ] && exit 0
exit $rc
LAUNCH
chmod +x /tmp/launch-bnet.sh

source /opt/gow/launch-comp.sh
launcher /tmp/launch-bnet.sh
