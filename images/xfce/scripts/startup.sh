#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting XFCE4"

CFG_DIR=$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/

exec xfce4-session

