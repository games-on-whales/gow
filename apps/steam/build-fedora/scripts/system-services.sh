#!/bin/sh

source /opt/gow/bash-lib/utils.sh

# Steam Big Picture First time setup needs a couple of services

mkdir -p /run/dbus
dbus-daemon --system --fork --nosyslog
gow_log "*** DBus started ***"
# On Fedora the bluez package installs bluetoothd at
# /usr/libexec/bluetooth/bluetoothd (not on $PATH). Debian/Ubuntu put it
# under /usr/sbin, which /is/ on $PATH. Resolve via command -v first,
# fall back to the known Fedora location so this survives either base.
BLUETOOTHD="$(command -v bluetoothd || true)"
: "${BLUETOOTHD:=/usr/libexec/bluetooth/bluetoothd}"
"$BLUETOOTHD" --nodetach &
gow_log "*** Bluez started ***"
NetworkManager
gow_log "*** NetworkManager started ***"
# Watchdog will stop steam when selecting Turn off, Suspend or Restart from the Steam power menu
steamos-dbus-watchdog.sh &
gow_log "*** D-Bus Watchdog started ***"

STEAMDIR="${HOME}/.local/share/Steam"
STEAMDIR_LEGACY="${HOME}/.steam/steam"
# Detect (but do not auto-migrate) an Ubuntu-layout legacy install.
#
# Earlier versions of this script auto-copied ~/.steam/steam into
# ~/.local/share/Steam, but every variant of that approach has been wrong:
#   - rm -rf + mv looped on every restart and wiped login state (#324)
#   - cp -aT assumes enough free space at $STEAMDIR, which is false when
#     ~/.steam is bind-mounted from a separate (large) drive that holds
#     the library while $HOME sits on the small root filesystem
#   - any data move risks destroying a user's library if it fails partway
#
# True Ubuntu→Fedora migrations are rare. Detect the situation, log a
# clear message, and let the user decide. Steam will still launch — the
# wrapper's symlink logic refuses to clobber a real legacy directory and
# will print its own warning.
if [ -d "$STEAMDIR_LEGACY" ] && [ ! -L "$STEAMDIR_LEGACY" ]; then
  gow_log "*** Legacy ~/.steam/steam directory detected (not a symlink). ***"
  gow_log "*** Auto-migration is disabled. If Steam does not find your   ***"
  gow_log "*** library, move ~/.steam/steam/* into ~/.local/share/Steam/ ***"
  gow_log "*** manually, then remove ~/.steam so the symlink can be      ***"
  gow_log "*** recreated on the next boot.                               ***"
  # Bail before Steam launches: starting Steam against a real (non-symlink)
  # ~/.steam/steam can confuse the client and a half-broken first run is
  # the kind of thing that ends in lost data. Better to fail cont-init
  # loudly so the human notices than to limp on.
  exit 1
fi

# Install Decky Loader. The PluginLoader binary is baked into the image
# at /opt/decky/PluginLoader during build (see Dockerfile), so this
# first-run install is offline and deterministic — the cont-init smoke
# test no longer depends on the GitHub releases API rate limit, and
# fresh user containers do not roll the rate-limit dice on every start.
if [ ! -f "$HOME/homebrew/services/PluginLoader" ]; then
  gow_log "Installing Decky Loader"
  mkdir -p "$STEAMDIR"
  touch "$STEAMDIR/.cef-enable-remote-debugging"
  echo "Steam directory: $STEAMDIR"
  mkdir -p "$HOME/homebrew/services/"
  cp /opt/decky/PluginLoader "$HOME/homebrew/services/PluginLoader"
  chmod +x "$HOME/homebrew/services/PluginLoader"
fi

# Start Decky Loader
gow_log "*** Decky Loader started ***"
$HOME/homebrew/services/PluginLoader &

disown
