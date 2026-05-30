#!/bin/bash
# install_retroarch_cores.sh — populate ~/.config/retroarch/cores for rom_launcher.sh
# Run inside ES-DE / Pegasus / RetroArch container images (Ubuntu + libretro PPA).
set -euo pipefail

CORES_DIR="${1:-/cores}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$CORES_DIR"

apt-get update -qq
apt-get install -y --no-install-recommends wget unzip ca-certificates python3

mapfile -t pkgs < <(
    apt-cache search '^libretro-' 2>/dev/null \
        | awk '{print $1}' \
        | grep -vE '^kodi|dev|doc|info|common|dbgsym' \
        | sort -u
)
if ((${#pkgs[@]} > 0)); then
    apt-get install -y --no-install-recommends "${pkgs[@]}" || true
fi

shopt -s nullglob
for libdir in /usr/lib/*/libretro; do
    [[ -d "$libdir" ]] || continue
    cp -n "$libdir"/*.so "$CORES_DIR"/ 2>/dev/null || true
done

fetch_buildbot_core() {
    local core="$1"
    local zip="/tmp/${core}_libretro.so.zip"
    local url="https://buildbot.libretro.com/nightly/linux/x86_64/latest/${core}_libretro.so.zip"
    if ! wget -q -O "$zip" "$url"; then
        echo "WARN: buildbot fetch failed for ${core} (${url})" >&2
        rm -f "$zip"
        return 1
    fi
    if ! unzip -o -q "$zip" -d "$CORES_DIR"; then
        echo "WARN: unzip failed for ${core}" >&2
        rm -f "$zip"
        return 1
    fi
    rm -f "$zip"
}

mapfile -t required < <(
    python3 - <<'PY'
from required_cores import ROM_LAUNCHER_CORES
for core in ROM_LAUNCHER_CORES:
    print(core)
PY
)

for core in "${required[@]}"; do
    [[ -f "${CORES_DIR}/${core}_libretro.so" ]] && continue
    fetch_buildbot_core "$core" || true
done

python3 - <<PY
from pathlib import Path
import os
from required_cores import CORE_SYMLINK_FALLBACKS, ROM_LAUNCHER_CORES

cores = Path("${CORES_DIR}")
for core in ROM_LAUNCHER_CORES:
    dest = cores / f"{core}_libretro.so"
    if dest.exists():
        continue
    fallback = CORE_SYMLINK_FALLBACKS.get(core)
    if not fallback:
        continue
    src = cores / fallback
    if src.is_file():
        dest.symlink_to(fallback)
        print(f"Linked {fallback} -> {dest.name}")
PY

missing=0
for core in "${required[@]}"; do
    [[ -f "${CORES_DIR}/${core}_libretro.so" ]] || { echo "MISSING: ${core}_libretro.so" >&2; missing=$((missing + 1)); }
done

count=$(ls -1 "$CORES_DIR"/*.so 2>/dev/null | wc -l | tr -d ' ')
echo "RetroArch cores installed: ${count} (${missing} required still missing)"
exit 0
