#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

LOG "Waiting for X Server $DISPLAY to be available"
wait-x11

LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG "Starting Minecraft with DISPLAY=${DISPLAY} and LOG_LEVEL=${LOG_LEVEL}"

ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

# Start gnome-keyring-daemon
if [ ! -z "${KEYPASS}" ]; then
  eval "$(dbus-launch --sh-syntax)"
  mkdir -p ~/.cache
  mkdir -p ~/.local/share/keyrings # where the automatic keyring is created
  # 1. Create the keyring manually
  eval "$(printf $KEYPASS | gnome-keyring-daemon --unlock)"
  # 2. Start the daemon, using the password to unlock the just-created keyring:
  eval "$(printf $KEYPASS | /usr/bin/gnome-keyring-daemon --start)"
else
  LOG "[WARN] KEYPASS environment variable does not exist."
  LOG "You will need to log into your account each time the container is started."
fi

# Start Minecraft-launcher. Use `sudo` to make sure that group membership gets reloaded
exec sudo -u $(whoami) -E /usr/bin/minecraft-launcher
