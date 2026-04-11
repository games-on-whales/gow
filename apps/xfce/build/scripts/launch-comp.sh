#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

function launcher() {
  export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/retro/.local/share/flatpak/exports/share:/usr/local/share/:/usr/share/

  if [ ! -d "$HOME/.config/xfce4" ]; then
    # set default config
    mkdir -p $HOME/.config/xfce4
    cp -r /opt/gow/xfce4/* $HOME/.config/xfce4/
    
    # add flathub repo
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    # XFCE4 will only run in X11 so we have to disable wayland
    flatpak override --user --nosocket=wayland

    # Create commun folders
    mkdir ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos
    chmod 755 ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos
  fi

  #
  # Launch DBUS
  sudo /opt/gow/startdbus

  export DESKTOP_SESSION=xfce
  export XDG_CURRENT_DESKTOP=XFCE
  export XDG_SESSION_TYPE="x11"
  export _JAVA_AWT_WM_NONREPARENTING=1
  export GDK_BACKEND=x11
  export MOZ_ENABLE_WAYLAND=0
  export QT_QPA_PLATFORM="xcb"
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  export QT_ENABLE_HIGHDPI_SCALING=1
  export DISPLAY=:0
  export REAL_WAYLAND_DISPLAY=$WAYLAND_DISPLAY
  export GTK_THEME=Arc-Dark:dark
  unset WAYLAND_DISPLAY

  local xfce_start_cmd=""
  if command -v startxfce4 >/dev/null 2>&1; then
    xfce_start_cmd="startxfce4"
  elif command -v xfce4-session >/dev/null 2>&1; then
    xfce_start_cmd="xfce4-session"
  else
    gow_log "[start] XFCE session launcher not found (expected startxfce4 or xfce4-session)"
    return 1
  fi

  #
  # Start Xwayland and xfce4
  dbus-run-session -- bash -E -c "WAYLAND_DISPLAY=\$REAL_WAYLAND_DISPLAY Xwayland :0 & sleep 2 && exec ${xfce_start_cmd}"
}
