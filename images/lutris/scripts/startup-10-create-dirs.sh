#!/bin/bash -e

# Create the basic file structe lutris expects, using symlinks to /var/lutris
# It is expected that a volume be mounted at /var/volume such that game
# installation can be shared by multiple images and containers.

gow_log "[start-create-dirs] Begin"

# "library" will contain information about available games and installed games.
if [ ! -d "/var/lutris/library" ]
then
    gow_log "[start-create-dirs] Creating /var/lutris/library"
    mkdir -p "/var/lutris/library"
fi

if [ ! -e "${HOME}/.config/lutris/games" ]
then
    gow_log "[start-create-dirs] Creating symlink ${HOME}/.config/lutris/games -> /var/lutris/library"
    mkdir -p "${HOME}/.config/lutris"
    ln -s "/var/lutris/library" "${HOME}/.config/lutris/games"
fi

# "share" contains stateful information, and sharing share allows the system to have a common games library.
if [ ! -d "/var/lutris/share" ]
then
    gow_log "[start-create-dirs] Creating /var/lutris/share"
    mkdir -p "/var/lutris/share"
fi

if [ ! -e "${HOME}/.local/share/lutris" ]
then
    gow_log "[start-create-dirs] Creating symlink ${HOME}/.local/share/lutris -> /var/lutris/share"
    mkdir -p "${HOME}/.local/share"
    ln -s "/var/lutris/share" "${HOME}/.local/share/lutris"
fi

# "Games" will contain actual installation files.
if [ ! -d "/var/lutris/Games" ]
then
    gow_log "[start-create-dirs] Creating /var/lutris/Games"
    mkdir -p "/var/lutris/Games"
fi

# configuration file, pointing lutris at the Games directory.
if [ ! -f "${HOME}/.config/lutris/system.yml" ]
then
    gow_log "[start-create-dirs] Creating lutris system config file."
    cp "/opt/gow/lutris-system.yml" "${HOME}/.config/lutris/system.yml"
fi

# configuration file, telling lutris to ignore missing wine
if [ ! -f "${HOME}/.config/lutris/lutris.conf" ]
then
    gow_log "[start-create-dirs] Creating lutris config file."
    cp "/opt/gow/lutris-lutris.conf" "${HOME}/.config/lutris/lutris.conf"
fi

gow_log "[start-create-dirs] End"
