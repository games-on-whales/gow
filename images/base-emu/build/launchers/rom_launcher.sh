#!/bin/bash
EMULATOR=$1
ROM=$2

# Mount location where we will mount both zip files and iso files
ISO_MOUNT_LOCATION=/media/iso_mount

function launch_ps3 {

  local ROM_FILE="$1"

  # Mount the folder/file if it's an iso
  if [[ $ROM_FILE == *.iso ]]; then
    echo "Mounting: ${ROM_FILE} to ${ISO_MOUNT_LOCATION}"
    fuseiso "${ROM_FILE}" ${ISO_MOUNT_LOCATION}
    ROM_FILE=${ISO_MOUNT_LOCATION}
  fi

  # Launch the game
  /Applications/rpcs3-emu.AppImage --appimage-extract-and-run  "${ROM_FILE}"

  # Unmount (if we mounted the ISO)
  if [[ "${ROM_FILE}" == "${ISO_MOUNT_LOCATION}" ]]; then
    echo "UnMounting: ${ISO_MOUNT_LOCATION}"
    fusermount -u ${ISO_MOUNT_LOCATION}
  fi
}

function launch_scummvm {

  local ROM_FILE="$1"

  # Mount the folder/file if it's an iso
  if [[ $ROM_FILE == *.zip ]]; then
    echo "Mounting: ${ROM_FILE} to ${ISO_MOUNT_LOCATION}"
    fuse-zip -o ro "${ROM_FILE}" ${ISO_MOUNT_LOCATION}
    ROM_FILE=${ISO_MOUNT_LOCATION}
  fi

  # Find the .scummvm filename
  SCUMMVM_FILE=`ls ${ISO_MOUNT_LOCATION}/*.scummvm`

  # Launch the game
  retroarch -L ~/.config/retroarch/cores/scummvm_libretro.so ${ISO_MOUNT_LOCATION}/${SCUMMVM_FILE}

  # Unmount (if we mounted the ISO)
  if [[ "${ROM_FILE}" == "${ISO_MOUNT_LOCATION}" ]]; then
    echo "UnMounting: ${ISO_MOUNT_LOCATION}"
    fusermount -u ${ISO_MOUNT_LOCATION}
  fi
}

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
["n64"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mupen64plus_next_libretro.so \"${ROM}\"" \
["naomi"]="retroarch --fullscreen -L ~/.config/retroarch/cores/flycast_libretro.so \"${ROM}\"" \
["neogeo"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fbneo_libretro.so \"${ROM}\"" \
["nes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fceumm_libretro.so \"${ROM}\"" \
["ngp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["ngpc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["psp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/ppsspp_libretro.so \"${ROM}\"" \
["psx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx_rearmed_libretro.so \"${ROM}\"" \
["ps2"]="/Applications/pcsx2-emu.AppImage --appimage-extract-and-run \"${ROM}\"" \
["ps3"]="launch_ps3  \"${ROM}\"" \
["saturn"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_saturn_libretro.so \"${ROM}\"" \
["sega32x"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["segacd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["scummvm"]="launch_scummvm \"${ROM}\"" \
["snes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/snes9x_libretro.so \"${ROM}\"" \
["snes_widescreen"]="retroarch --fullscreen -L ~/.config/retroarch/cores/bsnes_hd_beta_libretro.so \"${ROM}\"" \
["virtualboy"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_vb_libretro.so \"${ROM}\"" \
["wii"]="/Applications/dolphin-emu.AppImage --appimage-extract-and-run --batch --exec=\"${ROM}\"" \
["wiiu"]="/Applications/cemu-emu.AppImage --appimage-extract-and-run -f -g \"${ROM}\"" \
["wonderswan"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["wonderswancolor"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["xbox"]="/Applications/xemu-emu.AppImage --appimage-extract-and-run -full-screen -dvd_path \"${ROM}\"" \
["xbox360"]="/Applications/launchers/xenia.sh --fullscreen \"${ROM}\"" \
)

echo "Running command: ${EMULATOR_COMMAND[${EMULATOR}]}"
eval ${EMULATOR_COMMAND[${EMULATOR}]}
