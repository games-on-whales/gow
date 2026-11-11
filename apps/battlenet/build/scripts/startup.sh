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

# Moonlight's paste (Ctrl+Alt+Shift+V) arrives as Ctrl+Shift+U <hex digits> per character, which GTK understands and
# Wine does not. Sway catches those keys and /opt/gow/bnet-paste.sh turns them into a real clipboard paste.
# BNET_PASTE_HELPER=0 (environment variable of the app) turns this off.
if [ "${BNET_PASTE_HELPER:-1}" != "0" ]; then
    mkdir -p /tmp/bnet-paste && chmod 777 /tmp/bnet-paste
    KEY='exec sh -c "printf %s >> /tmp/bnet-paste/cur; /opt/gow/bnet-paste.sh arm"'
    {
        echo "bindcode --no-repeat Control+Shift+30 mode \"bnet-unicode\", ${KEY/\%s/\' \'}"
        echo 'mode "bnet-unicode" {'
        echo "    bindcode --no-repeat Control+Shift+30 ${KEY/\%s/\' \'}"
        n=0
        for code in 19 10 11 12 13 14 15 16 17 18; do
            echo "    bindcode --no-repeat Control+Shift+$code ${KEY/\%s/$n}"; n=$((n + 1))
        done
        for pair in 38:a 56:b 54:c 40:d 26:e 41:f; do
            echo "    bindcode --no-repeat Control+Shift+${pair%%:*} ${KEY/\%s/${pair##*:}}"
        done
        echo '}'
    } >> "$HOME/.config/sway/custom-cfg"
fi

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

# Many hosts start containers with a soft open-files limit of 1024 (hard limit far higher). pressure-vessel
# needs more while it assembles the runtime and sometimes fails with "Too many open files", which leaves a
# gray Sway; Wine's esync also wants a high limit. Raise the soft limit to the hard limit.
ulimit -n "$(ulimit -Hn)" 2>/dev/null || true
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

# BNET_PROTON_VERSION (environment variable of the app or bnet.env), e.g. BNET_PROTON_VERSION=GE-Proton11-12: use that
# GE-Proton release instead of the one baked into the image. It is downloaded once into $PERSIST_DIR/proton and
# reused at the next starts. Unset, or equal to the baked version, nothing is downloaded. If the download fails the
# baked version is used. Progress goes to bnet-proton.log in the persistent folder. The Steam Linux Runtime stays
# the baked one, so only releases that use the same runtime generation will work.
if [ -n "${BNET_PROTON_VERSION:-}" ]; then
    PLOG="$PERSIST_DIR/bnet-proton.log"
    BAKED_PROTON=$(basename "$(readlink -f "$PROTONPATH")"); BAKED_PROTON=${BAKED_PROTON%-x86_64}
    PROTON_DIR="$PERSIST_DIR/proton/$BNET_PROTON_VERSION"
    if [ "$BNET_PROTON_VERSION" = "$BAKED_PROTON" ]; then
        echo "$(date '+%F %T') $BNET_PROTON_VERSION is the version baked into the image" >> "$PLOG"
    elif ! [[ "$BNET_PROTON_VERSION" =~ ^GE-Proton[0-9A-Za-z._-]+$ ]]; then
        echo "$(date '+%F %T') BNET_PROTON_VERSION='$BNET_PROTON_VERSION' is not a GE-Proton tag, using $BAKED_PROTON" | tee -a "$PLOG"
    else
        if [ ! -x "$PROTON_DIR/proton" ]; then
            echo "$(date '+%F %T') downloading $BNET_PROTON_VERSION" | tee -a "$PLOG"
            PTMP="$PERSIST_DIR/proton/.tmp-$$"
            rm -rf "$PTMP"; mkdir -p "$PTMP"
            PURL=$(curl -fsSL "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/tags/$BNET_PROTON_VERSION" 2>>"$PLOG" \
                | grep browser_download_url | grep '\.tar\.gz' | grep -v aarch64 | head -1 | cut -d'"' -f4) || PURL=""
            if [ -n "$PURL" ] && curl -fsSL "$PURL" 2>>"$PLOG" | tar -xz -C "$PTMP" 2>>"$PLOG" && PEXTRACTED=$(ls -d "$PTMP"/*/ 2>/dev/null | head -1) && [ -x "${PEXTRACTED}proton" ]; then
                rm -rf "$PROTON_DIR"
                mv "${PEXTRACTED%/}" "$PROTON_DIR"
                echo "$(date '+%F %T') $BNET_PROTON_VERSION installed in $PROTON_DIR" >> "$PLOG"
            else
                echo "$(date '+%F %T') download of $BNET_PROTON_VERSION failed (release not found or no network), using $BAKED_PROTON" | tee -a "$PLOG"
            fi
            rm -rf "$PTMP"
        fi
        if [ -x "$PROTON_DIR/proton" ]; then
            export PROTONPATH="$PROTON_DIR"
            echo "$(date '+%F %T') using $BNET_PROTON_VERSION" >> "$PLOG"
        fi
    fi
fi

# BNET_DEBUG=1 (e.g. `export BNET_DEBUG=1` in bnet.env) turns on the diagnostics: session-trace.log (timeline of
# processes and windows) and umu-last.log (output of the launcher, end printed when a start fails). Off by default.
BNET_DEBUG="${BNET_DEBUG:-0}"

TRACE="$PERSIST_DIR/session-trace.log"
T0=$(date +%s)
trace() { printf '%s +%ss %s\n' "$(date +%T)" "$(( $(date +%s) - T0 ))" "$*" >> "$TRACE"; }
if [ "$BNET_DEBUG" = "1" ]; then
    [ -f "$TRACE" ] && mv -f "$TRACE" "$TRACE.1"
    trace "wrapper started"
fi

# BNET_EXEC (environment variable of the app or bnet.env), e.g. BNET_EXEC="launch Fen" for Diablo IV: start
# Battle.net.exe --exec="<value>" instead of the launcher so the app goes straight into that game (see below).
BNET_DIR="$PERSIST_DIR/drive_c/Program Files (x86)/Battle.net"
if [ -n "${BNET_EXEC:-}" ]; then
    BNET_CMD=("$BNET_DIR/Battle.net.exe" "--exec=$BNET_EXEC")
else
    BNET_CMD=("$BNET_DIR/Battle.net Launcher.exe")
fi

# With BNET_DEBUG=1 the launcher output goes to umu-last.log (previous run: umu-last.log.1) and a failed start
# prints the end of it to the container log, without the pressure-vessel hard-link warnings that hide the real error.
UMU_LOG="$PERSIST_DIR/umu-last.log"
if [ "$BNET_DEBUG" = "1" ]; then
    [ -f "$UMU_LOG" ] && mv -f "$UMU_LOG" "$UMU_LOG.1"
    umu-run "${BNET_CMD[@]}" > "$UMU_LOG" 2>&1 &
else
    umu-run "${BNET_CMD[@]}" &
fi
UMU_PID=$!

# A cold-started client logs the --exec argument but does not act on it. Sent to a running, logged-in client
# (a second Battle.net.exe hands its arguments over and exits) it starts the game. So once this session's
# client log shows the account loaded and the version checks done, send BNET_EXEC again (at most twice).
# Progress goes to bnet-exec.log in the persistent folder. (Idea and first version: a Diablo IV user on NVIDIA.)
if [ -n "${BNET_EXEC:-}" ]; then
    (
        EXLOG="$PERSIST_DIR/bnet-exec.log"
        LOGDIR="$PERSIST_DIR/drive_c/users/steamuser/AppData/Local/Battle.net/Logs"
        T0X=$(date +%s)
        LOGF=""
        launched() { [ -n "$LOGF" ] && grep -q 'InstallManager.*Launched ' "$LOGF"; }
        for attempt in 1 2; do
            for i in $(seq 1 300); do   # up to 10 minutes, enough for a login with 2FA
                kill -0 "$UMU_PID" 2>/dev/null || exit 0
                LOGF=$(ls -t "$LOGDIR"/battle.net-*.log 2>/dev/null | head -1)
                if [ -n "$LOGF" ] && [ "$(stat -c %Y "$LOGF")" -ge "$T0X" ]; then
                    launched && exit 0
                    grep -q 'Received GameLevelInfo' "$LOGF" && break
                fi
                LOGF=""
                sleep 2
            done
            [ -n "$LOGF" ] || exit 0
            for i in $(seq 1 15); do grep -q 'Game finished versioning' "$LOGF" && break; sleep 2; done
            sleep 3
            launched && exit 0
            echo "$(date '+%F %T') client ready, no game started: sending --exec=$BNET_EXEC again (attempt $attempt)" >> "$EXLOG"
            # umu-run defaults to Proton's "waitforexitandrun" verb, which first waits until every Wine process of
            # the prefix has exited, i.e. until the session is over; "run" starts the second Battle.net.exe now.
            # Without PROTON_LOG: Proton would replace the running session's log file with a new one.
            PROTON_VERB=run env -u PROTON_LOG umu-run "$BNET_DIR/Battle.net.exe" "--exec=$BNET_EXEC" > "$PERSIST_DIR/bnet-exec-umu.log" 2>&1 &
            for i in $(seq 1 30); do
                sleep 2
                if launched; then echo "$(date '+%F %T') game launched" >> "$EXLOG"; exit 0; fi
            done
        done
        echo "$(date '+%F %T') game still not launched after 2 attempts, giving up" >> "$EXLOG"
    ) &
fi

# Timeline of the session in $PERSIST_DIR/session-trace.log (previous run: session-trace.log.1):
# a line whenever the set of running Windows processes or of windows changes. Only with BNET_DEBUG=1.
if [ "$BNET_DEBUG" = "1" ]; then
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
                [ "$BNET_DEBUG" = "1" ] && trace "auto-exit: client gone for ${gone}s, no game left, stopping umu-run"
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
[ "$BNET_DEBUG" = "1" ] && trace "umu-run exited rc=$rc"
if [ "$BNET_DEBUG" = "1" ]; then
    # One line per session in session-summary.log, to compare good and bad starts.
    CEFLOG=$(ls -t "$PERSIST_DIR"/drive_c/users/steamuser/AppData/Local/Battle.net/Logs/libcef-*.log 2>/dev/null | head -1)
    ERRDIR="$PERSIST_DIR/drive_c/users/steamuser/AppData/Local/Battle.net/Errors"
    printf '%s rc=%s up=%ss nofile=%s host=%s freetype_warn=%s gpu_fail=%s crash_reports=%s\n' \
        "$(date '+%F %T')" "$rc" "$(( $(date +%s) - T0 ))" "$(ulimit -n)" "$(hostname)" \
        "$(grep -c 'FreeType' "$UMU_LOG" 2>/dev/null || true)" \
        "$( [ -n "$CEFLOG" ] && grep -a -c 'GPU process launch failed' "$CEFLOG" || true)" \
        "$(find "$ERRDIR" -name '*Crash.txt' -newermt "@$T0" 2>/dev/null | wc -l)" \
        >> "$PERSIST_DIR/session-summary.log"
fi
if [ "$BNET_DEBUG" = "1" ] && [ "$rc" != 0 ] && [ ! -f /tmp/bnet-auto-exit ]; then
    echo "umu-run failed (rc=$rc), end of $UMU_LOG:"
    grep -vE 'W: (For best|Unable to create|Falling back)' "$UMU_LOG" 2>/dev/null | tail -n 40
fi
# Exit 0 after a requested stop so the compositor wrapper (exec ... && killall sway) ends the session
[ -f /tmp/bnet-auto-exit ] && exit 0
exit $rc
LAUNCH
chmod +x /tmp/launch-bnet.sh

source /opt/gow/launch-comp.sh
launcher /tmp/launch-bnet.sh
