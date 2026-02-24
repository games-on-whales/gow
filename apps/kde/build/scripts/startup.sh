#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}

# Shadow kwin_wayland_wrapper so that we can pass args to kwin wrapper
# whilst being launched by plasma-session
mkdir -p $XDG_RUNTIME_DIR/nested_kde
cat <<EOF > $XDG_RUNTIME_DIR/nested_kde/kwin_wayland_wrapper
#!/bin/sh
/usr/bin/kwin_wayland_wrapper --width $GAMESCOPE_WIDTH --height $GAMESCOPE_HEIGHT --wayland-display $WAYLAND_DISPLAY --xwayland --no-lockscreen \$@
EOF
chmod a+x $XDG_RUNTIME_DIR/nested_kde/kwin_wayland_wrapper
export PATH=$XDG_RUNTIME_DIR/nested_kde:$PATH

# For xwayland
mkdir -p /tmp/.X11-unix
chmod +t /tmp/.X11-unix
chmod 700 $XDG_RUNTIME_DIR

cat <<EOF > $XDG_RUNTIME_DIR/gow_start_kde
#!/bin/bash

source /opt/gow/bash-lib/utils.sh

gow_log "[start] Starting pipewire"
pipewire &

gow_log "[start] Starting KDE"
startplasma-wayland
EOF

chmod +x $XDG_RUNTIME_DIR/gow_start_kde

dbus-run-session -- $XDG_RUNTIME_DIR/gow_start_kde
