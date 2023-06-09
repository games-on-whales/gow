#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Install RPCS3 firmware from bios folder"
/home/retro/Applications/rpcs3-emu.AppImage --installfw /home/retro/bioses/PS3UPDAT.PUP