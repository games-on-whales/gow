#!/bin/bash
mkdir -p /var/run/dbus
dbus-daemon --system --fork --nosyslog
