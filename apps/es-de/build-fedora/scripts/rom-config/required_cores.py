#!/usr/bin/env python3
"""Core names required by rom_launcher.sh (without _libretro.so suffix)."""

from __future__ import annotations

# Keep in sync with gow/images/base-emu/build/launchers/rom_launcher.sh
ROM_LAUNCHER_CORES: tuple[str, ...] = (
    "opera",
    "mame",
    "puae",
    "stella",
    "a5200",
    "prosystem",
    "virtualjaguar",
    "mednafen_lynx",
    "flycast",
    "gambatte",
    "mgba",
    "picodrive",
    "genesis_plus_gx",
    "mupen64plus_next",
    "fbneo",
    "fceumm",
    "mednafen_ngp",
    "ppsspp",
    "pcsx_rearmed",
    "mednafen_saturn",
    "scummvm",
    "snes9x",
    "bsnes_hd_beta",
    "mednafen_vb",
    "mednafen_wswan",
)

# If the primary core is unavailable, symlink this existing core instead.
CORE_SYMLINK_FALLBACKS: dict[str, str] = {
    "fceumm": "nestopia_libretro.so",
    "pcsx_rearmed": "mednafen_psx_libretro.so",
    "picodrive": "genesis_plus_gx_libretro.so",
}
