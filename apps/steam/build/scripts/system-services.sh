#!/bin/sh

source /opt/gow/bash-lib/utils.sh

# Steam Big Picture First time setup needs a couple of services

mkdir -p /run/dbus
dbus-daemon --system --fork --nosyslog
gow_log "*** DBus started ***"
bluetoothd --nodetach &
gow_log "*** Bluez started ***"
NetworkManager
gow_log "*** NetworkManager started ***"
# Watchdog will stop steam when selecting Turn off, Suspend or Restart from the Steam power menu
steamos-dbus-watchdog.sh &
gow_log "*** D-Bus Watchdog started ***"

# Install Decky Loader
if [ ! -f "$HOME/homebrew/services/PluginLoader" ]; then
  gow_log "Installing Decky Loader"
  mkdir -p "$HOME/.steam/steam/"
  touch "$HOME/.steam/.cef-enable-remote-debugging"
  mkdir -p "$HOME/homebrew/services/"
  github_download "SteamDeckHomebrew/decky-loader" ".assets[]|select(.name|(\"PluginLoader\")).browser_download_url" "PluginLoader"
  chmod +x PluginLoader
  mv PluginLoader "$HOME/homebrew/services"
fi

# Start Decky Loader
gow_log "*** Decky Loader started ***"
$HOME/homebrew/services/PluginLoader &

disown
