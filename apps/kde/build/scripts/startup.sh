#!/bin/bash
echo "[INIT] Entrypoint started..."
echo "[INIT] WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "[INIT] XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"

# Fix DNS resolution inside the container
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Start system-level services: D-Bus, Polkit, NetworkManager
mkdir -p /run/dbus
dbus-daemon --system --fork
/usr/lib/polkit-1/polkitd --no-debug &
mkdir -p /run/NetworkManager
NetworkManager --no-daemon &
sleep 2
nmcli dev set eth0 managed yes 2>/dev/null || true

# Create required X11/ICE directories
mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
mkdir -p /tmp/.ICE-unix && chmod 1777 /tmp/.ICE-unix

# Make Wolf runtime dir + sockets accessible to the retro user
chmod 755 /run/user/wolf 2>/dev/null || true
chmod 666 /run/user/wolf/wayland-* 2>/dev/null || true
chmod 666 /run/user/wolf/pulse-socket 2>/dev/null || true

# Create the standard XDG_RUNTIME_DIR for UID 1000
USER_RUNTIME_DIR="/run/user/1000"
mkdir -p "$USER_RUNTIME_DIR" && chmod 0700 "$USER_RUNTIME_DIR" && chown -R retro:retro "$USER_RUNTIME_DIR"

# Ensure all KDE config/cache dirs exist
mkdir -p /home/retro/.config
mkdir -p /home/retro/.cache
mkdir -p /home/retro/.local/share
chown -R retro:retro /home/retro

WOLF_RUNTIME_DIR="/run/user/wolf"
echo "[INIT] Waiting for Wolf Wayland display socket at $WOLF_RUNTIME_DIR/${WAYLAND_DISPLAY:-wayland-0}..."
for i in $(seq 1 50); do
    if [ -e "$WOLF_RUNTIME_DIR/${WAYLAND_DISPLAY:-wayland-0}" ]; then
        echo "[INIT] Found Wayland socket!"
        break
    fi
    sleep 0.1
done

if [ -n "$WAYLAND_DISPLAY" ] && [ -e "$WOLF_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    ln -sf "$WOLF_RUNTIME_DIR/$WAYLAND_DISPLAY" "$USER_RUNTIME_DIR/$WAYLAND_DISPLAY"
    echo "[INIT] Linked Wayland socket: $WAYLAND_DISPLAY"
else
    echo "[ERROR] Wayland socket not found!"
    ls -la "$WOLF_RUNTIME_DIR/" 2>/dev/null || true
fi

if [ -e "$WOLF_RUNTIME_DIR/pulse-socket" ]; then
    mkdir -p "$USER_RUNTIME_DIR/pulse"
    ln -sf "$WOLF_RUNTIME_DIR/pulse-socket" "$USER_RUNTIME_DIR/pulse/native"
    chown -R retro:retro "$USER_RUNTIME_DIR/pulse"
    echo "[INIT] Linked PulseAudio socket"
fi

if [ -d /dev/dri ]; then chmod -R 777 /dev/dri 2>/dev/null || true; fi

cat << "INNEREOF" > /home/retro/start.sh
#!/bin/bash
ulimit -c 0 2>/dev/null || true
echo "[START] Setting up user environment..."
export HOME=/home/retro
export USER=retro
export LOGNAME=retro
export XDG_RUNTIME_DIR="/run/user/1000"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin${PATH:+:$PATH}"

export DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"
export XDG_CONFIG_HOME="/home/retro/.config"
export XDG_CACHE_HOME="/home/retro/.cache"
export XDG_DATA_HOME="/home/retro/.local/share"
export XDG_DATA_DIRS="/home/retro/.local/share:/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/home/retro/.config:/etc/xdg"

export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=KDE
export DESKTOP_SESSION=plasma
export KDE_SESSION_VERSION=6
export KDE_FULL_SESSION=true
export XDG_MENU_PREFIX=plasma-
export KSCREEN_BACKEND=QScreen

export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=kde
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1

export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export WLR_NO_HARDWARE_CURSORS=1
export KWIN_FORCE_SW_CURSOR=1

kwriteconfig6 --file startkderc --group General --key systemdBoot false

export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --session --fork --print-address)
echo "[START] D-Bus session started at $DBUS_SESSION_BUS_ADDRESS"

rm -rf /home/retro/.cache
rm -rf /home/retro/.config/session
rm -rf /home/retro/.config/plasma*
rm -rf /home/retro/.config/kded6rc
rm -rf /home/retro/.local/share/kxmlgui5
rm -rf /home/retro/.local/share/kxmlgui6
rm -rf /home/retro/.local/share/kscreenlocker

pipewire >/dev/null 2>&1 &
wireplumber >/dev/null 2>&1 &
sleep 1

xdg-user-dirs-update
kbuildsycoca6 --noincremental >/dev/null 2>&1

NESTED_WIDTH=${GAMESCOPE_WIDTH:-1920}
NESTED_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
KWIN_SOCKET="wayland-kde"

rm -f "$XDG_RUNTIME_DIR/$KWIN_SOCKET" 2>/dev/null || true

cleanup() {
    kill $KWIN_PID 2>/dev/null || true
}
trap cleanup EXIT TERM INT

echo "[START] Launching KWin Wayland in background..."
kwin_wayland --xwayland --no-lockscreen --width ${NESTED_WIDTH} --height ${NESTED_HEIGHT} --socket ${KWIN_SOCKET} >/dev/null 2>&1 &
KWIN_PID=$!

for i in $(seq 1 50); do
    if [ -e "$XDG_RUNTIME_DIR/$KWIN_SOCKET" ]; then
        echo "[START] KWin Wayland socket is ready!"
        break
    fi
    if ! kill -0 $KWIN_PID 2>/dev/null; then
        echo "[FATAL] KWin process exited before creating Wayland socket!"
        exit 1
    fi
    sleep 0.1
done

# CRITICAL FIX: Ensure X11/Xwayland is fully ready before launching KDE components
echo "[START] Waiting for KWin Xwayland socket to prevent crashes..."
for i in $(seq 1 50); do
    if ls /tmp/.X11-unix/X* 1> /dev/null 2>&1; then
        export DISPLAY=:$(ls /tmp/.X11-unix/ | tr -d 'X' | head -n 1)
        echo "[START] Xwayland socket is ready! Exported DISPLAY=$DISPLAY"
        break
    fi
    sleep 0.1
done
sleep 2

if [ ! -e "$XDG_RUNTIME_DIR/$KWIN_SOCKET" ]; then
    echo "[FATAL] KWin failed to create socket!"
    exit 1
fi

export WAYLAND_DISPLAY=$KWIN_SOCKET

echo "[START] Launching Splash Screen..."
ksplashqml Plasma >/dev/null 2>&1 &

echo "[START] Launching KDE Daemon (kded6)..."
kded6 >/dev/null 2>&1 &
sleep 2

echo "[START] Launching Session Manager (ksmserver)..."
# Wrapping ksmserver in a subshell ensures no core dumps can ever spill, even on failure
(ulimit -c 0; ksmserver >/dev/null 2>&1 &)
sleep 1

echo "[START] Launching Plasma Shell..."
plasmashell
EXIT_CODE=$?

# If plasmashell crashed with a segfault (139/134), pass it to trigger the 60s sleep.
# If it exited cleanly (like when you click Log Out), force code 0 to close instantly.
if [ "$EXIT_CODE" -eq 139 ] || [ "$EXIT_CODE" -eq 134 ]; then
    exit $EXIT_CODE
else
    exit 0
fi
INNEREOF

chmod +x /home/retro/start.sh
chown retro:retro /home/retro/start.sh

echo "[INIT] Handing execution over to retro..."
setpriv --reuid=1000 --regid=1000 --init-groups -- /home/retro/start.sh
EXIT_CODE=$?
echo ""
echo "[INFO] Container process finished with code $EXIT_CODE."

# Instant Close on Clean Logout vs 60s Hold on Crash
if [ "$EXIT_CODE" -ne 0 ]; then
    echo "[TIMER] App crashed or exited with an error. Holding open for 60 seconds so you can read this log..."
    sleep 60
else
    echo "[INFO] Clean logout confirmed! Closing the container instantly."
fi
exit $EXIT_CODE