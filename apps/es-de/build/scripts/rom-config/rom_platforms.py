"""Shared ROM platform definitions for GOW frontends (ES-DE, Pegasus, RetroArch)."""

from __future__ import annotations

from pathlib import Path

# Wolf ES-DE profile home (uid 1000 / user retro).
LAUNCHERS_PROFILE_DIR = "/home/retro/Applications/launchers"

_DISC = (
    ".7z .7Z .zip .ZIP .iso .ISO .bin .BIN .cue .CUE .chd .CHD "
    ".rvz .RVZ .cso .CSO .m3u .M3U .pbp .PBP"
)
_CART = ".7z .7Z .zip .ZIP .bin .BIN"
_ARCADE = ".7z .7Z .zip .ZIP"

# folder -> (display name, ES-DE theme/platform, file extensions, rom_launcher supported)
PLATFORMS: dict[str, tuple[str, str, str, bool]] = {
    "3do": ("3DO", "3do", _DISC, True),
    "amiga": ("Commodore Amiga", "amiga", _DISC, True),
    "amigacd32": ("Commodore Amiga CD32", "amigacd32", _DISC, True),
    "arcade": ("Arcade", "arcade", _ARCADE, True),
    "atari2600": ("Atari 2600", "atari2600", f".a26 .A26 {_CART}", True),
    "atari5200": ("Atari 5200", "atari5200", f".a52 .A52 {_CART}", True),
    "atari7800": ("Atari 7800", "atari7800", f".a78 .A78 {_CART}", True),
    "atarijaguar": ("Atari Jaguar", "atarijaguar", f".j64 .J64 .jag .JAG {_CART}", True),
    "atarijaguarcd": ("Atari Jaguar CD", "atarijaguarcd", _DISC, True),
    "atarilynx": ("Atari Lynx", "atarilynx", f".lnx .LNX .o .O {_CART}", True),
    "atarist": ("Atari ST", "atarist", f".st .ST .msa .MSA .zip .ZIP .7z .7Z", False),
    "dreamcast": ("Sega Dreamcast", "dreamcast", f".gdi .GDI .cdi .CDI .chd .CHD {_DISC}", True),
    "gb": ("Nintendo Game Boy", "gb", f".gb .GB .zip .ZIP .7z .7Z", True),
    "gbc": ("Nintendo Game Boy Color", "gbc", f".gbc .GBC .gb .GB .zip .ZIP .7z .7Z", True),
    "gba": ("Nintendo Game Boy Advance", "gba", f".gba .GBA .zip .ZIP .7z .7Z", True),
    "gc": ("Nintendo GameCube", "gc", f".gcz .GCZ .iso .ISO .rvz .RVZ .nfo .NFO {_DISC}", True),
    "genesis": (
        "Sega Genesis",
        "genesis",
        f".md .MD .gen .GEN .smd .SMD .bin .BIN .7z .7Z .zip .ZIP",
        True,
    ),
    "mastersystem": ("Sega Master System", "mastersystem", f".sms .SMS .zip .ZIP .7z .7Z", True),
    "megacd": ("Sega Mega-CD", "megacd", _DISC, True),
    "model2": ("Sega Model 2", "model2", _ARCADE, True),
    "model3": ("Sega Model 3", "model3", _ARCADE, False),
    "n64": ("Nintendo 64", "n64", f".n64 .N64 .v64 .V64 .z64 .Z64 .zip .ZIP .7z .7Z", True),
    "naomi": ("Sega Naomi", "naomi", _ARCADE, True),
    "neogeo": ("SNK Neo Geo", "neogeo", f".zip .ZIP .7z .7Z", True),
    "nes": (
        "Nintendo Entertainment System",
        "nes",
        ".fds .FDS .nes .NES .unf .UNF .unif .UNIF .7z .7Z .zip .ZIP",
        True,
    ),
    "ngp": ("SNK Neo Geo Pocket", "ngp", f".ngp .NGP .zip .ZIP .7z .7Z", True),
    "ngpc": ("SNK Neo Geo Pocket Color", "ngpc", f".ngc .NGC .zip .ZIP .7z .7Z", True),
    "psp": (
        "Sony PlayStation Portable",
        "psp",
        f".iso .ISO .cso .CSO .pbp .PBP .7z .7Z .zip .ZIP",
        True,
    ),
    "psx": ("Sony PlayStation", "psx", _DISC, True),
    "ps2": (
        "Sony PlayStation 2",
        "ps2",
        ".bin .BIN .chd .CHD .ciso .CISO .cso .CSO .iso .ISO .mdf .MDF .img .IMG .7z .7Z .zip .ZIP",
        True,
    ),
    "ps3": ("Sony PlayStation 3", "ps3", f".iso .ISO .ps3 .PS3 .zip .ZIP .7z .7Z", True),
    "saturn": ("Sega Saturn", "saturn", _DISC, True),
    "scummvm": ("ScummVM", "scummvm", ".zip .ZIP .7z .7Z .scummvm .SCUMMVM", True),
    "sega32x": ("Sega 32X", "sega32x", f".32x .32X .bin .BIN .7z .7Z .zip .ZIP", True),
    "segacd": ("Sega CD", "segacd", _DISC, True),
    "snes": (
        "Super Nintendo",
        "snes",
        ".sfc .SFC .smc .SMC .bin .BIN .fig .FIG .7z .7Z .zip .ZIP",
        True,
    ),
    "snes_widescreen": ("Super Nintendo Widescreen", "snes", ".sfc .SFC .smc .SMC .7z .7Z .zip .ZIP", True),
    "switch": ("Nintendo Switch", "switch", f".nsp .NSP .xci .XCI .nca .NCA .7z .7Z .zip .ZIP", True),
    "virtualboy": ("Nintendo Virtual Boy", "virtualboy", f".vb .VB .7z .7Z .zip .ZIP", True),
    "wii": ("Nintendo Wii", "wii", f".wbfs .WBFS .iso .ISO .rvz .RVZ .7z .7Z .zip .ZIP", True),
    "wiiu": ("Nintendo Wii U", "wiiu", f".wud .WUD .wux .WUX .rpx .RPX .7z .7Z .zip .ZIP", True),
    "wonderswan": ("Bandai WonderSwan", "wonderswan", f".ws .WS .7z .7Z .zip .ZIP", True),
    "wonderswancolor": ("Bandai WonderSwan Color", "wonderswancolor", f".wsc .WSC .7z .7Z .zip .ZIP", True),
    "xbox": ("Microsoft Xbox", "xbox", f".iso .ISO .xiso .XISO .7z .7Z .zip .ZIP", True),
    "xbox360": ("Microsoft Xbox 360", "xbox360", f".iso .ISO .xex .XEX .7z .7Z .zip .ZIP", True),
}

# Backend per platform folder — must stay in sync with rom_launcher.sh in base-emu.
PLATFORM_EMULATOR: dict[str, str] = {
    "3do": "retroarch",
    "arcade": "retroarch",
    "amiga": "retroarch",
    "amigacd32": "retroarch",
    "atari2600": "retroarch",
    "atari5200": "retroarch",
    "atari7800": "retroarch",
    "atarijaguar": "retroarch",
    "atarijaguarcd": "retroarch",
    "atarilynx": "retroarch",
    "dreamcast": "retroarch",
    "gb": "retroarch",
    "gbc": "retroarch",
    "gba": "retroarch",
    "gc": "dolphin",
    "genesis": "retroarch",
    "mastersystem": "retroarch",
    "megacd": "retroarch",
    "model2": "retroarch",
    "n64": "retroarch",
    "naomi": "retroarch",
    "neogeo": "retroarch",
    "nes": "retroarch",
    "ngp": "retroarch",
    "ngpc": "retroarch",
    "psp": "retroarch",
    "psx": "retroarch",
    "ps2": "pcsx2",
    "ps3": "rpcs3",
    "saturn": "retroarch",
    "sega32x": "retroarch",
    "segacd": "retroarch",
    "scummvm": "retroarch",
    "snes": "retroarch",
    "snes_widescreen": "retroarch",
    "switch": "citron",
    "virtualboy": "retroarch",
    "wii": "dolphin",
    "wiiu": "cemu",
    "wonderswan": "retroarch",
    "wonderswancolor": "retroarch",
    "xbox": "xemu",
    "xbox360": "xenia",
}

_EMULATOR_LAUNCHER_SCRIPT: dict[str, str] = {
    "retroarch": "retroarch.sh",
    "dolphin": "dolphin.sh",
    "pcsx2": "pcsx2.sh",
    "rpcs3": "rpcs3.sh",
    "cemu": "cemu.sh",
    "citron": "citron.sh",
    "xemu": "xemu.sh",
    "xenia": "xenia.sh",
}

# Custom Scripts launcher scripts (container paths under /Applications/launchers).
# name -> display name (description is derived from PLATFORM_EMULATOR + PLATFORMS).
CUSTOM_SCRIPT_LAUNCHERS: dict[str, str] = {
    "retroarch.sh": "RetroArch",
    "dolphin.sh": "Dolphin",
    "pcsx2.sh": "PCSX2",
    "rpcs3.sh": "RPCS3",
    "cemu.sh": "Cemu",
    "citron.sh": "Citron",
    "xemu.sh": "Xemu",
    "xenia.sh": "Xenia",
}


def launcher_script_for_platform(folder: str) -> str | None:
    emu = PLATFORM_EMULATOR.get(folder)
    if emu is None:
        return None
    return _EMULATOR_LAUNCHER_SCRIPT.get(emu)


def compatible_esde_systems_for_launcher(script_name: str) -> list[str]:
    """ES-DE platform display names this launcher can run (rom_launcher-compatible only)."""
    names: list[str] = []
    for folder, (_, _theme, _ext, has_launcher) in PLATFORMS.items():
        if not has_launcher:
            continue
        if launcher_script_for_platform(folder) != script_name:
            continue
        names.append(PLATFORMS[folder][0])
    return names


def launcher_description(script_name: str) -> str:
    systems = compatible_esde_systems_for_launcher(script_name)
    if systems:
        return "ES-DE systems: " + ", ".join(systems)
    stem = Path(script_name).stem.replace("_", " ").title()
    return f"Launch {stem}"

# RetroArch core .so required by rom_launcher.sh (unique set).
RETROARCH_CORES: frozenset[str] = frozenset(
    {
        "opera_libretro.so",
        "mame_libretro.so",
        "puae_libretro.so",
        "stella_libretro.so",
        "a5200_libretro.so",
        "prosystem_libretro.so",
        "virtualjaguar_libretro.so",
        "mednafen_lynx_libretro.so",
        "flycast_libretro.so",
        "gambatte_libretro.so",
        "mgba_libretro.so",
        "picodrive_libretro.so",
        "genesis_plus_gx_libretro.so",
        "mupen64plus_next_libretro.so",
        "fbneo_libretro.so",
        "fceumm_libretro.so",
        "mednafen_ngp_libretro.so",
        "ppsspp_libretro.so",
        "pcsx_rearmed_libretro.so",
        "mednafen_saturn_libretro.so",
        "scummvm_libretro.so",
        "snes9x_libretro.so",
        "bsnes_hd_beta_libretro.so",
        "mednafen_vb_libretro.so",
        "mednafen_wswan_libretro.so",
    }
)

# Buildbot fallback when apt packages omit a core (core name without _libretro.so suffix).
RETROARCH_CORE_BUILDbot: dict[str, str] = {
    "fceumm": "fceumm",
    "bsnes_hd_beta": "bsnes_hd_beta",
    "mame": "mame",
    "mednafen_saturn": "mednafen_saturn",
    "mednafen_vb": "mednafen_vb",
    "mednafen_wswan": "mednafen_wswan",
    "mednafen_ngp": "mednafen_ngp",
    "mednafen_lynx": "mednafen_lynx",
    "prosystem": "prosystem",
    "a5200": "a5200",
    "virtualjaguar": "virtualjaguar",
    "opera": "opera",
}

# Optional per-platform standalone emulator commands (ES-DE alternative launchers).
_L = LAUNCHERS_PROFILE_DIR
PLATFORM_STANDALONE_COMMANDS: dict[str, list[tuple[str, str]]] = {
    "gc": [
        ("Dolphin", f"{_L}/dolphin.sh --exec %ROM%"),
    ],
    "wii": [
        ("Dolphin", f"{_L}/dolphin.sh --exec %ROM%"),
    ],
    "ps2": [
        ("PCSX2", f"{_L}/pcsx2.sh %ROM%"),
    ],
    "ps3": [
        ("RPCS3", f"{_L}/rpcs3.sh %ROM%"),
    ],
    "wiiu": [
        ("Cemu", f"{_L}/cemu.sh -g %ROM%"),
    ],
    "switch": [
        ("Citron", f"{_L}/citron.sh -f -g %ROM%"),
    ],
    "xbox": [
        ("Xemu", f"{_L}/xemu.sh %ROM%"),
    ],
    "xbox360": [
        ("Xenia", f"{_L}/xenia.sh %ROM% --fullscreen"),
    ],
}

# Map platform folder -> Custom Scripts launcher for manual emulator access (ES-DE UI hint).
PLATFORM_CUSTOM_SCRIPT: dict[str, str] = {
    folder: script
    for folder in PLATFORMS
    if (script := launcher_script_for_platform(folder)) is not None
    and script != "retroarch.sh"
}

def custom_scripts_esde_block() -> str:
    return f"""    <system>
        <name>Custom Scripts</name>
        <fullname>Custom Scripts</fullname>
        <path>{LAUNCHERS_PROFILE_DIR}</path>
        <extension>.desktop .sh</extension>
        <command label="Various">%ENABLESHORTCUTS% %EMULATOR_OS-SHELL% %ROM%</command>
        <platform>pc, pcwindows</platform>
        <theme>Custom Scripts</theme>
    </system>"""


CUSTOM_SCRIPTS_ESDE = custom_scripts_esde_block()

# Host ROM folder names (ES-DE / Steam ROM Manager layouts) -> rom_launcher.sh platform id.
ROM_FOLDER_ALIASES: dict[str, str] = {
    "cps": "arcade",
    "cps1": "arcade",
    "cps2": "arcade",
    "cps3": "arcade",
    "fba": "arcade",
    "fbneo": "arcade",
    "mame": "arcade",
    "mame-advmame": "arcade",
    "famicom": "nes",
    "fds": "nes",
    "gamegear": "mastersystem",
    "megadrive": "genesis",
    "megadrivejp": "genesis",
    "megaduck": "genesis",
    "saturnjp": "saturn",
    "segacd": "segacd",
    "sfc": "snes",
    "snesna": "snes",
    "neogeocd": "neogeo",
    "neogeocdjp": "neogeo",
}
