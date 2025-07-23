#!/usr/bin/env bash

set -e

gow_log "**** Configure firewall ****"

# block outgoing connections
ufw default reject outgoing
# allow dns
ufw allow out to any port 53
# get all ip's for ankiweb.net
ANKI_WEB_IPS="$(dig +short ankiweb.net)"
# allow access to ankiweb.net
echo "$ANKI_WEB_IPS" | while read -r IP; do ufw allow out from any to $IP; done
# enable firewall
ufw enable

gow_log "DONE"