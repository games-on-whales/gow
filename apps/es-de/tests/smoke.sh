#!/usr/bin/env bash
# ES-DE is an AppImage fetched from GitLab at build time.

source /smoke-common/lib.sh

assert_path /Applications/esde.AppImage /media /bioses /ROMs
assert_path /opt/gow/startup-app.sh /etc/cont-init.d/setup-de.sh

# AppImage should at least be executable.
if [[ -x /Applications/esde.AppImage ]]; then
  ok "esde.AppImage is executable"
else
  bad "esde.AppImage is executable"
fi

smoke_report
