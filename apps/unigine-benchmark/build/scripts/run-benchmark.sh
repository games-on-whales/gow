#!/usr/bin/env bash

set -e

source /opt/gow/bash-lib/utils.sh

BENCHMARK="${1:-}"
if [[ -z "$BENCHMARK" ]]; then
    gow_log "Usage: $0 <benchmark>"
    gow_log "Available benchmarks: heaven, valley, superposition"
    exit 1
fi

MANGOHUD_CMD="mangohud"
if [[ -n "$DISABLE_MANGOHUD" ]]; then
    unset MANGOHUD_CMD
    gow_log "[mangohud] Disabled, running without mangohud"
fi

# Sadly unigine-benchmarks don't render over the waybar properly so we need to change the layer to bottom
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
TEMP_WAYBAR_CONFIG="$(mktemp)"
jsoncq.sh '.layer = "bottom"' "$WAYBAR_CONFIG" > "$TEMP_WAYBAR_CONFIG"
mv "$TEMP_WAYBAR_CONFIG" "$WAYBAR_CONFIG"
gow_log "[waybar] Changed layer to bottom for better compatibility with Unigine benchmarks"

if [[ "$BENCHMARK" == "heaven" ]]; then
    BENCHMARK_CMD="$HOME/.unigine/heaven/heaven"
elif [[ "$BENCHMARK" == "valley" ]]; then
    BENCHMARK_CMD="$HOME/.unigine/valley/valley"
elif [[ "$BENCHMARK" == "superposition" ]]; then
    BENCHMARK_CMD="$HOME/.unigine/superposition/Superposition"
else
    gow_log "ERROR: Unknown benchmark '$BENCHMARK'. Available benchmarks: heaven, valley, superposition."
    exit 1
fi

WORKING_DIR=$(dirname "$BENCHMARK_CMD")
cd "$WORKING_DIR" || exit 1

gow_log "[start] Running benchmark: $BENCHMARK"
"${MANGOHUD_CMD:-}" "$BENCHMARK_CMD"
