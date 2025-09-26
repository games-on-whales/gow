#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting Hyprland"

# Only copy waybar default config if it doesn't exist
mkdir -p $HOME/.config/waybar
cp -u /cfg/waybar/* $HOME/.config/waybar/

# This will be picked up as $CACHE_HOME by hyprland
mkdir -p $HOME/.cache

# This will be picked up as $XDG_DATA_HOME by hyprland
mkdir -p $HOME/.local/share/

# We have to manually pass the resolution to hyprland
mkdir -p $HOME/.config/sway/
cp /cfg/hypr/hyprlandd.conf $HOME/.config/hypr/hyprlandd.conf
# Modify the config file for res and to launch the app at the end
GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
echo "setting resolution to ${GAMESCOPE_WIDTH}x${GAMESCOPE_HEIGHT}@${GAMESCOPE_REFRESH}"
echo "monitor = , ${GAMESCOPE_WIDTH}x${GAMESCOPE_HEIGHT}@${GAMESCOPE_REFRESH}, 0x0, 1" >> $HOME/.config/hypr/hyprlandd.conf
dbus-run-session -- Hyprland