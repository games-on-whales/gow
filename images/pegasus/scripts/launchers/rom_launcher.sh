#!/bin/bash
EMULATOR=$1
ROM=$2

# dictionary of emulator to command to run
declare -A EMULATOR_COMMAND=( \
["arcade"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mame_libretro.so \"${ROM}\"" \
["atari2600"]="retroarch --fullscreen -L ~/.config/retroarch/cores/stella_libretro.so \"${ROM}\"" \
["gb"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so \"${ROM}\"" \
["gbc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so \"${ROM}\"" \
["gba"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mgba_libretro.so \"${ROM}\"" \
["gc"]="/Applications/dolphin-emu.AppImage --appimage-extract-and-run --batch --exec=\"${ROM}\"" \
["genesis"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["n64"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mupen64plus_next_libretro.so \"${ROM}\"" \
["nes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fceumm_libretro.so \"${ROM}\"" \
["ngp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["ngpc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["psx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx_rearmed_libretro.so \"${ROM}\"" \
["ps2"]="/Applications/pcsx2-emu-Qt.AppImage --appimage-extract-and-run \"${ROM}\"" \
["sega32x"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["snes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/snes9x_libretro.so \"${ROM}\"" \
["snes_widescreen"]="retroarch --fullscreen -L ~/.config/retroarch/cores/bsnes_hd_beta_libretro.so \"${ROM}\"" \
["virtualboy"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_vb_libretro.so \"${ROM}\"" \
["wii"]="/Applications/dolphin-emu.AppImage --appimage-extract-and-run --batch --exec=\"${ROM}\"" \
["xbox"]="/Applications/xemu-emu.AppImage --appimage-extract-and-run -full-screen -dvd_path \"${ROM}\"" \
)

echo "Running command: ${EMULATOR_COMMAND[${EMULATOR}]}"
eval ${EMULATOR_COMMAND[${EMULATOR}]}
