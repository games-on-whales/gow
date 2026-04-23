#!/usr/bin/env bash
# Smoke test for the steam image. Steam itself can't be launched headlessly
# (it wants dbus, gamescope, X, audio), so we check the structural
# invariants: binary present, custom patched bwrap installed, jupiter/steamos
# helper shims in place, session helpers on PATH.

source /smoke-common/lib.sh

# Steam is shipped by Ubuntu as a tiny launcher script under /usr/games
# that downloads the real runtime on first run. Make sure the launcher
# binary + its 32-bit libs are there.
#
# NOTE: `mangoapp` is deliberately not asserted here. It is present on
# the Fedora base-app (Fedora's mangohud RPM bundles it) but absent on
# the Ubuntu base-app (upstream MangoHud tarball drops it). Steam's
# startup.sh calls it unconditionally; on Ubuntu the call is a silent
# no-op. See images/base-app/build/Dockerfile for why we accept this.
assert_has steam ibus-daemon dbus-daemon zenity bwrap

# The Dockerfile replaces /usr/bin/zenity with a symlink to /usr/bin/true
# so Steam's updater UI doesn't prompt. Catch regressions that restore the
# real zenity (would hang Steam on first launch).
if [[ -L /usr/bin/zenity ]] && [[ "$(readlink -f /usr/bin/zenity)" == /usr/bin/true ]]; then
  ok "/usr/bin/zenity -> /usr/bin/true (Steam auto-update shim)"
else
  bad "/usr/bin/zenity -> /usr/bin/true (Steam auto-update shim missing)"
fi

# Custom bwrap built from source with ignore_capabilities.patch.
assert_shared_ok /usr/bin/bwrap
assert_version bwrap --version

# SteamOS compatibility shims the Dockerfile installs.
assert_path /usr/bin/steamos-session-select \
            /usr/bin/steamos-update \
            /usr/bin/jupiter-biosupdate \
            /usr/bin/steamos-polkit-helpers/steamos-update \
            /usr/bin/steamos-polkit-helpers/jupiter-biosupdate \
            /usr/local/bin/steamos-dbus-watchdog.sh

# Steam itself only gets invoked as the retro user (won't run as root).
run_as_user steam --version

smoke_report
