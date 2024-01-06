#!/bin/bash
EMULATOR=$1
ROM=$2

# dictionary of emulator to command to run
declare -A EMULATOR_COMMAND=( \
["3do"]="retroarch --fullscreen -L ~/.config/retroarch/cores/opera_libretro.so \"${ROM}\"" \
["arcade"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mame_libretro.so \"${ROM}\"" \
["amiga"]="retroarch --fullscreen -L ~/.config/retroarch/cores/puae_libretro.so \"${ROM}\"" \
["amigacd32"]="retroarch --fullscreen -L ~/.config/retroarch/cores/puae_libretro.so \"${ROM}\"" \
["atari2600"]="retroarch --fullscreen -L ~/.config/retroarch/cores/stella_libretro.so \"${ROM}\"" \
["atari5200"]="retroarch --fullscreen -L ~/.config/retroarch/cores/a5200_libretro.so \"${ROM}\"" \
["atari7800"]="retroarch --fullscreen -L ~/.config/retroarch/cores/prosystem_libretro.so \"${ROM}\"" \
["atarijaguar"]="retroarch --fullscreen -L ~/.config/retroarch/cores/virtualjaguar_libretro.so \"${ROM}\"" \
["atarijaguarcd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/virtualjaguar_libretro.so \"${ROM}\"" \
["atarilynx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_lynx_libretro.so \"${ROM}\"" \
["dreamcast"]="retroarch --fullscreen -L ~/.config/retroarch/cores/flycast_libretro.so \"${ROM}\"" \
["gb"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so \"${ROM}\"" \
["gbc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/gambatte_libretro.so \"${ROM}\"" \
["gba"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mgba_libretro.so \"${ROM}\"" \
["gc"]="/Applications/dolphin-emu.AppImage --appimage-extract-and-run --batch --exec=\"${ROM}\"" \
["genesis"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["megacd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["model2"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mame_libretro.so \"${ROM}\"" \
["model3"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mame_libretro.so \"${ROM}\"" \
["n64"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mupen64plus_next_libretro.so \"${ROM}\"" \
["naomi"]="retroarch --fullscreen -L ~/.config/retroarch/cores/flycast_libretro.so \"${ROM}\"" \
["neogeo"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fbneo_libretro.so \"${ROM}\"" \
["nes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fceumm_libretro.so \"${ROM}\"" \
["ngp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["ngpc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["psp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/ppsspp_libretro.so \"${ROM}\"" \
["psx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx_rearmed_libretro.so \"${ROM}\"" \
["ps2"]="/Applications/pcsx2-emu-Qt.AppImage --appimage-extract-and-run \"${ROM}\"" \
["ps3"]="/Applications/rpcs3-emu.AppImage --appimage-extract-and-run  \"${ROM}\"" \
["saturn"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_saturn_libretro.so \"${ROM}\"" \
["sega32x"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["segacd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["snes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/snes9x_libretro.so \"${ROM}\"" \
["snes_widescreen"]="retroarch --fullscreen -L ~/.config/retroarch/cores/bsnes_hd_beta_libretro.so \"${ROM}\"" \
["switch"]="/Applications/yuzu-emu.AppImage --appimage-extract-and-run -f -g \"${ROM}\"" \
["virtualboy"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_vb_libretro.so \"${ROM}\"" \
["wii"]="/Applications/dolphin-emu.AppImage --appimage-extract-and-run --batch --exec=\"${ROM}\"" \
["wiiu"]="/Applications/cemu-emu.AppImage --appimage-extract-and-run -f -g \"${ROM}\"" \
["wonderswan"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["wonderswancolor"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["xbox"]="/Applications/xemu-emu.AppImage --appimage-extract-and-run -full-screen -dvd_path \"${ROM}\"" \
)

echo "Running command: ${EMULATOR_COMMAND[${EMULATOR}]}"
eval ${EMULATOR_COMMAND[${EMULATOR}]}
