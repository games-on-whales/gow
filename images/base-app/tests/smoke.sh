#!/usr/bin/env bash
# Smoke test for base-app -- the layer that adds the Wayland/X stack every
# GUI app sits on top of. Regressions here (missing .so from a kisak-mesa
# ppa change, xwayland patch not applying, gamescope version bump) cascade
# into every single app image, so this is where the most assertions live.

source /smoke-common/lib.sh

# Compositor / display-server binaries every app launcher depends on.
assert_has Xwayland gamescope sway mangohud mangoplot sdl2-jstest xdpyinfo xkbcomp kitty waybar

# The base-app Dockerfile builds a patched Xwayland from source; the patched
# binary must win over the distro copy via PATH and the /usr/bin symlink.
if [[ -L /usr/bin/Xwayland ]] && [[ "$(readlink -f /usr/bin/Xwayland)" == /usr/local/bin/Xwayland ]]; then
  ok "/usr/bin/Xwayland -> /usr/local/bin/Xwayland (patched build active)"
else
  bad "/usr/bin/Xwayland -> /usr/local/bin/Xwayland (patched build not installed)"
fi
assert_shared_ok /usr/local/bin/Xwayland

# Each binary must at least load + print its banner. 10s timeout in lib.sh
# protects against anything that decides to wait for a display.
assert_version Xwayland -version
assert_version gamescope --help
assert_version sway --version
assert_version mangohud --version
assert_version sdl2-jstest --help

# Keymap compile dir must be writable by non-root (retro), or Xwayland
# blows up with EACCES at runtime. Covered by the Dockerfile but easy to
# regress if the COPY order changes.
if [[ -d /var/lib/xkb ]]; then
  perms=$(stat -c '%a' /var/lib/xkb)
  if [[ "$perms" == "1777" || "$perms" == "777" ]]; then
    ok "/var/lib/xkb writable by non-root ($perms)"
  else
    bad "/var/lib/xkb writable by non-root (perms=$perms)"
  fi
else
  bad "/var/lib/xkb exists"
fi

# The helper scripts the app layer sources.
assert_path /opt/gow/launch-comp.sh /opt/gow/wait-x11 /cfg/sway/config

smoke_report
