#!/bin/bash
# Refresh ROM library frontend configs from mounted /ROMs (Games on Whales).
set -euo pipefail

GOW_ROM_CONFIG_DIR="${GOW_ROM_CONFIG_DIR:-/opt/gow/rom-config}"
GENERATOR="${GOW_ROM_CONFIG_DIR}/generate_rom_library_configs.py"

if [[ ! -x "$GENERATOR" && ! -f "$GENERATOR" ]]; then
    echo "WARN: ROM library generator missing at ${GENERATOR}" >&2
    exit 0
fi

_esde_roms_args=()
_pegasus_roms_args=()
if [[ -d /ROMs ]]; then
    _esde_roms_args=(--roms-dir /ROMs)
    _pegasus_roms_args=(--roms-dir /ROMs --only-existing)
fi

gow_generate_esde_systems() {
    local dest="$1"
    mkdir -p "$(dirname "$dest")"
    python3 "$GENERATOR" --format esde "${_esde_roms_args[@]}" > "$dest"
    if ! grep -q '<name>Custom Scripts</name>' "$dest"; then
        echo "ERROR: ES-DE generator did not include Custom Scripts platform" >&2
        return 1
    fi
}

gow_refresh_esde_custom_scripts_gamelist() {
    local dest="$1"
    local launchers_dir="${2:-}"
    if [[ -z "$launchers_dir" ]]; then
        if [[ -d "${HOME}/Applications/launchers" ]]; then
            launchers_dir="${HOME}/Applications/launchers"
        else
            launchers_dir="/Applications/launchers"
        fi
    fi
    mkdir -p "$(dirname "$dest")"
    if [[ ! -d "$launchers_dir" ]]; then
        echo "WARN: Custom Scripts launchers dir missing: ${launchers_dir}" >&2
        return 0
    fi
    if [[ -f "$dest" ]]; then
        python3 "$GENERATOR" --format esde-custom-scripts-gamelist \
            --launchers-dir "$launchers_dir" --merge-gamelist "$dest"
    else
        python3 "$GENERATOR" --format esde-custom-scripts-gamelist \
            --launchers-dir "$launchers_dir" > "$dest"
    fi
}

gow_generate_pegasus_game_dirs() {
    local dest="$1"
    mkdir -p "$(dirname "$dest")"
    python3 "$GENERATOR" --format pegasus-game-dirs "${_pegasus_roms_args[@]}" > "$dest"
}

gow_generate_pegasus_rom_metadata() {
    local dest="$1"
    mkdir -p "$(dirname "$dest")"
    python3 "$GENERATOR" --format pegasus-metadata "${_pegasus_roms_args[@]}" > "$dest"
}
