#!/bin/bash
EMULATOR=$1
ROM=$2

# Profile-seeded launchers (repair-esde.sh); fall back to image path.
GOW_LAUNCHERS="${GOW_LAUNCHERS:-/home/retro/Applications/launchers}"
if [[ ! -d "$GOW_LAUNCHERS" ]]; then
    GOW_LAUNCHERS="/Applications/launchers"
fi

ISO_MOUNT_LOCATION=/media/iso_mount

function launch_ps3 {
    local ROM_FILE="$1"

    if [[ $ROM_FILE == *.iso ]]; then
        echo "Mounting: ${ROM_FILE} to ${ISO_MOUNT_LOCATION}"
        fuseiso "${ROM_FILE}" ${ISO_MOUNT_LOCATION}
        ROM_FILE=${ISO_MOUNT_LOCATION}
    fi

    "${GOW_LAUNCHERS}/rpcs3.sh" "${ROM_FILE}"

    if [[ "${ROM_FILE}" == "${ISO_MOUNT_LOCATION}" ]]; then
        echo "UnMounting: ${ISO_MOUNT_LOCATION}"
        fusermount -u ${ISO_MOUNT_LOCATION}
    fi
}

function launch_scummvm {
    local ROM_FILE="$1"

    if [[ $ROM_FILE == *.zip ]]; then
        echo "Mounting: ${ROM_FILE} to ${ISO_MOUNT_LOCATION}"
        fuse-zip -o ro "${ROM_FILE}" ${ISO_MOUNT_LOCATION}
        ROM_FILE=${ISO_MOUNT_LOCATION}
    fi

    SCUMMVM_FILE=`ls ${ISO_MOUNT_LOCATION}/*.scummvm`

    retroarch --fullscreen -L ~/.config/retroarch/cores/scummvm_libretro.so ${SCUMMVM_FILE}

    if [[ "${ROM_FILE}" == "${ISO_MOUNT_LOCATION}" ]]; then
        echo "UnMounting: ${ISO_MOUNT_LOCATION}"
        fusermount -u ${ISO_MOUNT_LOCATION}
    fi
}

function launch_nes {
    local ROM_FILE="$1"
    local CORE_DIR="${HOME}/.config/retroarch/cores"
    local CORE="fceumm_libretro.so"
    if [[ ! -f "${CORE_DIR}/${CORE}" && -f "${CORE_DIR}/nestopia_libretro.so" ]]; then
        CORE="nestopia_libretro.so"
    fi
    retroarch --fullscreen -L "${CORE_DIR}/${CORE}" "${ROM_FILE}"
}

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
["gc"]="${GOW_LAUNCHERS}/dolphin.sh --exec \"${ROM}\"" \
["genesis"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["mastersystem"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["megacd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["model2"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mame_libretro.so \"${ROM}\"" \
["n64"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mupen64plus_next_libretro.so \"${ROM}\"" \
["naomi"]="retroarch --fullscreen -L ~/.config/retroarch/cores/flycast_libretro.so \"${ROM}\"" \
["neogeo"]="retroarch --fullscreen -L ~/.config/retroarch/cores/fbneo_libretro.so \"${ROM}\"" \
["nes"]="launch_nes \"${ROM}\"" \
["ngp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["ngpc"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_ngp_libretro.so \"${ROM}\"" \
["psp"]="retroarch --fullscreen -L ~/.config/retroarch/cores/ppsspp_libretro.so \"${ROM}\"" \
["psx"]="retroarch --fullscreen -L ~/.config/retroarch/cores/pcsx_rearmed_libretro.so \"${ROM}\"" \
["ps2"]="${GOW_LAUNCHERS}/pcsx2.sh \"${ROM}\"" \
["ps3"]="launch_ps3 \"${ROM}\"" \
["saturn"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_saturn_libretro.so \"${ROM}\"" \
["sega32x"]="retroarch --fullscreen -L ~/.config/retroarch/cores/picodrive_libretro.so \"${ROM}\"" \
["segacd"]="retroarch --fullscreen -L ~/.config/retroarch/cores/genesis_plus_gx_libretro.so \"${ROM}\"" \
["scummvm"]="launch_scummvm \"${ROM}\"" \
["snes"]="retroarch --fullscreen -L ~/.config/retroarch/cores/snes9x_libretro.so \"${ROM}\"" \
["snes_widescreen"]="retroarch --fullscreen -L ~/.config/retroarch/cores/bsnes_hd_beta_libretro.so \"${ROM}\"" \
["switch"]="${GOW_LAUNCHERS}/citron.sh -f -g \"${ROM}\"" \
["virtualboy"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_vb_libretro.so \"${ROM}\"" \
["wii"]="${GOW_LAUNCHERS}/dolphin.sh --exec \"${ROM}\"" \
["wiiu"]="${GOW_LAUNCHERS}/cemu.sh -g \"${ROM}\"" \
["wonderswan"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["wonderswancolor"]="retroarch --fullscreen -L ~/.config/retroarch/cores/mednafen_wswan_libretro.so \"${ROM}\"" \
["xbox"]="${GOW_LAUNCHERS}/xemu.sh \"${ROM}\"" \
["xbox360"]="${GOW_LAUNCHERS}/xenia.sh \"${ROM}\"" \
)

echo "Running command: ${EMULATOR_COMMAND[${EMULATOR}]}"
eval ${EMULATOR_COMMAND[${EMULATOR}]}
