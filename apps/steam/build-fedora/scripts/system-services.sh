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

STEAMDIR="${HOME}/.local/share/Steam"
STEAMDIR_LEGACY="${HOME}/.steam/steam"
# Is the user coming from an Ubuntu installation?
if [ ! -h "$STEAMDIR_LEGACY" ]; then
  gow_log "*** Steam Legacy detected, moving steamapps to the new location ***"
  # -rf: on a fresh Fedora profile $STEAMDIR may not exist yet; rm -r
  # aborted the cont-init script with "No such file or directory" and
  # Steam never started (black screen → session killed). Same for the
  # legacy /.steam/ cleanup below, which may also be gone after prior
  # failed runs.
  rm -rf "$STEAMDIR"
  mv "$STEAMDIR_LEGACY" "$STEAMDIR"
  rm -rf "${HOME}/.steam/steam"
  ln -fs ${STEAMDIR} ${STEAMDIR_LEGACY}
fi

# Install Decky Loader
if [ ! -f "$HOME/homebrew/services/PluginLoader" ]; then
  gow_log "Installing Decky Loader"
  mkdir -p "$STEAMDIR"
  touch "$STEAMDIR/.cef-enable-remote-debugging"
  echo "Steam directory: $STEAMDIR"
  mkdir -p "$HOME/homebrew/services/"
  github_download "SteamDeckHomebrew/decky-loader" ".assets[]|select(.name|(\"PluginLoader\")).browser_download_url" "PluginLoader"
  chmod +x PluginLoader
  mv PluginLoader "$HOME/homebrew/services"
fi

# Start Decky Loader
gow_log "*** Decky Loader started ***"
$HOME/homebrew/services/PluginLoader &

disown
