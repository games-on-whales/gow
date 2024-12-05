#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Steam startup.sh"

# Recursively creating Steam necessary folders (https://github.com/ValveSoftware/steam-for-linux/issues/6492)
mkdir -p "$HOME/.steam/ubuntu12_32/steam-runtime"

# Use the new big picture mode by default
STEAM_STARTUP_FLAGS=${STEAM_STARTUP_FLAGS:-"-bigpicture"}

# Some game fixes taken from the Steam Deck
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

# Enable Mangoapp
# Note: Ubuntus Mangoapp doesn't support Presets, so disable this for now
#export STEAM_MANGOAPP_PRESETS_SUPPORTED=1
export STEAM_USE_MANGOAPP=1
export MANGOHUD_CONFIGFILE=$(mktemp /tmp/mangohud.XXXXXXXX)
# Enable horizontal mangoapp bar
export STEAM_MANGOAPP_HORIZONTAL_SUPPORTED=1

# Enable Variable Rate Shading
# Note: this only works on gallium drivers and with new enough mesa
#       unfortunately there is no good way to check and disable this flag otherwise
export STEAM_USE_DYNAMIC_VRS=1
export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp /tmp/radv_vrs.XXXXXXXX)
# To expose vram info from radv
export WINEDLLOVERRIDES=dxgi=n

# Initially write no_display to our config file
# so we don't get mangoapp showing up before Steam initializes
# on OOBE and stuff.
mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
echo "position=top-right" > "$MANGOHUD_CONFIGFILE"
echo "no_display" > "$MANGOHUD_CONFIGFILE"

# Prepare our initial VRS config file
# for dynamic VRS in Mesa.
mkdir -p "$(dirname "$RADV_FORCE_VRS_CONFIG_FILE")"
# By default don't do half shading
echo "1x1" > "$RADV_FORCE_VRS_CONFIG_FILE"


# Scaling support
export STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT=1

# Have SteamRT's xdg-open send http:// and https:// URLs to Steam
export SRT_URLOPEN_PREFER_STEAM=1

# Set input method modules for Qt/GTK that will show the Steam keyboard
export QT_IM_MODULE=steam
export GTK_IM_MODULE=Steam


if [ -n "$RUN_GAMESCOPE" ]; then
  # Enable support for xwayland isolation per-game in Steam
  # Note: This breaks without the additional steamdeck flags
  #export STEAM_MULTIPLE_XWAYLANDS=1
  #STEAM_STARTUP_FLAGS="${STEAM_STARTUP_FLAGS} -steamos3 -steamdeck -steampal"

  # We no longer need to set GAMESCOPE_EXTERNAL_OVERLAY from steam, mangoapp now does it itself
  export STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND=1

  # Setup socket for gamescope statistics shown in mango and steam
  # Create run directory file for startup and stats sockets
  tmpdir="$([[ -n ${XDG_RUNTIME_DIR+x} ]] && mktemp -p "$XDG_RUNTIME_DIR" -d -t gamescope.XXXXXXX)"
  socket="${tmpdir:+$tmpdir/startup.socket}"
  stats="${tmpdir:+$tmpdir/stats.pipe}"
  # Fail early if we don't have a proper runtime directory setup
  if [[ -z $tmpdir || -z ${XDG_RUNTIME_DIR+x} ]]; then
	echo >&2 "!! Failed to find run directory in which to create stats session sockets (is \$XDG_RUNTIME_DIR set?)"
	exit 0
  fi

  export GAMESCOPE_STATS="$stats"
  mkfifo -- "$stats"
  mkfifo -- "$socket"

  # Attempt to claim global session if we're the first one running (e.g. /run/1000/gamescope)
  linkname="gamescope-stats"
  #   shellcheck disable=SC2031 # (broken warning)
  sessionlink="${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/}${linkname}" # Account for XDG_RUNTIME_DIR="" (notfragileatall)
  lockfile="$sessionlink".lck
  exec 9>"$lockfile" # Keep as an fd such that the lock lasts as long as the session if it is taken
  if flock -n 9 && rm -f "$sessionlink" && ln -sf "$tmpdir" "$sessionlink"; then
	# Took the lock.  Don't blow up if those commands fail, though.
	echo >&2 "Claimed global gamescope stats session at \"$sessionlink\""
  else
	echo >&2 "!! Failed to claim global gamescope stats session"
  fi

  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}

  # shellcheck disable=SC2086
  /usr/games/gamescope -e ${GAMESCOPE_MODE} -R $socket -T $stats -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" &

  # Read the variables we need from the socket
  if read -r -t 3 response_x_display response_wl_display <> "$socket"; then
	export DISPLAY="$response_x_display"
	export GAMESCOPE_WAYLAND_DISPLAY="$response_wl_display"
	unset WAYLAND_DISPLAY
	# We're done!
  else
	echo "gamescope failed"
	exit 1
  fi

  # Start IBus to enable showing the steam on-screen keyboard
  /usr/bin/ibus-daemon -d -r --panel=disable --emoji-extension=disable
  # Launch mango
  mangoapp &

  # Start Steam
  # shellcheck disable=SC2086
  dbus-run-session -- /usr/games/steam ${STEAM_STARTUP_FLAGS}

elif [ -n "$RUN_SWAY" ]; then
  # Start IBus to enable showing the steam on-screen keyboard
  /usr/bin/ibus-daemon -d -r --panel=disable --emoji-extension=disable

  # Enable MangoHud for all vulkan (including Proton) games
  # unless the user has explicitly disabled it in config.
  export MANGOHUD=${MANGOHUD:-1}

  # Start Steam
  source /opt/gow/launch-comp.sh
  launcher /usr/games/steam ${STEAM_STARTUP_FLAGS}
else
  # shellcheck disable=SC2086
  exec /usr/games/steam ${STEAM_STARTUP_FLAGS}
fi
