#!/bin/bash
set -e

export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/usr/local/share:/usr/share

source /opt/gow/launch-comp.sh
launcher flatpak run --branch=stable --arch=x86_64 --command=Plex tv.plex.PlexHTPC
