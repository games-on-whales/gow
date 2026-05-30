#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

XENIA_WORKDIR="${HOME}/.local/share/Xenia/root"
mkdir -p "$XENIA_WORKDIR"

_xenia_bin() {
    local candidate
    for candidate in \
        /Applications/xenia-canary/xenia_canary \
        /Applications/xenia-canary/build/bin/Linux/Release/xenia_canary; do
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

XENIA_BIN=$(_xenia_bin) || {
    gow_log "ERROR: xenia_canary not found under /Applications/xenia-canary"
    exit 1
}

gow_log "Starting Xenia Canary (${XENIA_BIN}) DISPLAY=${DISPLAY} args: $*"
cd "$XENIA_WORKDIR"

for arg in "$@"; do
    if [[ "$arg" == "--fullscreen" ]]; then
        exec "$XENIA_BIN" "$@"
    fi
done

if [[ $# -eq 0 ]]; then
    exec "$XENIA_BIN" --fullscreen
fi

exec "$XENIA_BIN" "$@" --fullscreen
