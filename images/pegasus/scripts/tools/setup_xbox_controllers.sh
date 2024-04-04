#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

#########################################
# CEMU
#########################################
CEMU_CFG_DIR=$HOME/.config/Cemu
gow_log "CEMU - Copying controller bindings for Wolf, if not edited"
mkdir -p $CEMU_CFG_DIR/controllerProfiles/
cp -u /cfg/cemu/controllerProfiles/controller0.xml $CEMU_CFG_DIR/controllerProfiles/controller0.xml
cp -u /cfg/cemu/controllerProfiles/controller1.xml $CEMU_CFG_DIR/controllerProfiles/controller1.xml
cp -u /cfg/cemu/controllerProfiles/xbox.xml $CEMU_CFG_DIR/controllerProfiles/xbox.xml

#########################################
# Dolphin
#########################################
DOLPHIN_CFG=$HOME/.config/dolphin-emu
mkdir -p "$DOLPHIN_CFG"
gow_log "Dolphin - Copying controller config, if not edited"
cp -u /cfg/dolphin/GCPadNew.ini "$DOLPHIN_CFG/GCPadNew.ini"

#########################################
# RPCS3
#########################################
RPCS3_CFG_DIR=$HOME/.config/rpcs3
gow_log "RPCS3 - Copying controller bindings for Wolf, if not edited"
mkdir -p $RPCS3_CFG_DIR/input_configs/global/
cp -u /cfg/rpcs3/Default.yml $RPCS3_CFG_DIR/input_configs/global/Default.yml
