#!/bin/bash
EMULATOR=$1
ROM=$2

# dictionary of emulator to command to run
declare -A EMULATOR_COMMAND=( \
["gb"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so "${ROM}"" \
["gbc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so "${ROM}"" \
["gba"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mgba_libretro.so \"${ROM}\"" \
["gc"]="/usr/games/dolphin-emu --batch --exec=${ROM} " \
["genesis"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["nes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fceumm_libretro.so \"${ROM}\"" \
["psx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx_rearmed_libretro.so \"${ROM}\"" \
["ps2"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx2_libretro.so \"${ROM}\"" \
["sega32x"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["snes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/bsnes_hd_beta_libretro.so \"${ROM}\"" \
)

echo "Running command: ${EMULATOR_COMMAND[${EMULATOR}]}"
eval ${EMULATOR_COMMAND[${EMULATOR}]}
