#!/bin/bash
# Start the system dbus daemon. Don't use `service dbus start` -- it works
# on Ubuntu (sysvinit-utils ships /usr/sbin/service) but Fedora 43
# containers don't have it. dbus-daemon is the same binary both distros'
# service scripts eventually invoke, so just call it directly, keeping
# the init script portable across the Ubuntu and Fedora base-app variants.
set -e
mkdir -p /run/dbus
dbus-daemon --system --fork --nopidfile