#!/bin/sh

# Steam Big Picture First time setup needs a couple of services

dbus-daemon --system --fork --nosyslog
echo "*** DBus started ***"
bluetoothd --nodetach &
echo "*** Bluez started ***"
NetworkManager
echo "*** NetworkManager started ***"

disown
