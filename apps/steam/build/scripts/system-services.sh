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

# Install Decky Loader. The PluginLoader binary is baked into the image
# at /opt/decky/PluginLoader during build (see Dockerfile), so this
# first-run install is offline and deterministic — the cont-init smoke
# test no longer depends on the GitHub releases API rate limit, and
# fresh user containers do not roll the rate-limit dice on every start.
if [ ! -f "$HOME/homebrew/services/PluginLoader" ]; then
  gow_log "Installing Decky Loader"
  mkdir -p "$HOME/.steam/steam/"
  mkdir -p "$HOME/.steam/debian-installation/"
  touch "$HOME/.steam/debian-installation/.cef-enable-remote-debugging"
  mkdir -p "$HOME/homebrew/services/"
  cp /opt/decky/PluginLoader "$HOME/homebrew/services/PluginLoader"
  chmod +x "$HOME/homebrew/services/PluginLoader"
fi

# Start Decky Loader
gow_log "*** Decky Loader started ***"
$HOME/homebrew/services/PluginLoader &

disown
