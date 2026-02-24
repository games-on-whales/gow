#!/usr/bin/env bash

source /opt/gow/bash-lib/utils.sh

function shutdown_steam() {
    gow_log "[steamos-dbus-watchdog] Shutting down Steam..."
    "$HOME/.local/share/Steam/steam.sh" -shutdown
 -shutdown
    exit 0
}

gow_log "[steamos-dbus-watchdog] Starting D-Bus watcher for Steam shutdown..."
dbus-monitor --system "interface='org.freedesktop.login1.Manager'" | \
while read -r line; do
    if echo "$line" | grep -q "member=PowerOff"; then
        gow_log "[steamos-dbus-watchdog] Detected 'PowerOff' D-Bus call!"
        shutdown_steam
    fi

    if echo "$line" | grep -q "member=Reboot"; then
        gow_log "[steamos-dbus-watchdog] Detected 'Reboot' D-Bus call!"
        shutdown_steam
    fi

    if echo "$line" | grep -q "member=Suspend"; then
        gow_log "[steamos-dbus-watchdog] Detected 'Suspend' D-Bus call!"
        shutdown_steam
    fi
done
