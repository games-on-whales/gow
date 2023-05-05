#!/bin/bash

set -e

gow_log "**** Setting up Gamescope ****"

chown "${UNAME}":"${UNAME}" /usr/games/gamescope
setcap 'cap_sys_nice=eip' /usr/games/gamescope
