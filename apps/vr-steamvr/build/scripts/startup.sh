#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "VR Streaming startup.sh"

# Start system services needed for VR
gow_log "Starting system services..."
mkdir -p /run/dbus
dbus-daemon --system --fork --nosyslog
echo "*** DBus started ***"

# Start NetworkManager for network discovery
NetworkManager &
echo "*** NetworkManager started ***"

# Create necessary directories
mkdir -p "$HOME/.steam/ubuntu12_32/steam-runtime"
mkdir -p "$HOME/.local/share/alvr"
mkdir -p "$HOME/.config/openxr/1"

# Set up OpenXR runtime
gow_log "Setting up OpenXR runtime..."
export XR_RUNTIME_JSON=/home/retro/.config/openxr/1/active_runtime.json

# Copy ALVR config if not exists
if [ ! -f "$HOME/.local/share/alvr/session.json" ]; then
    gow_log "Copying default ALVR configuration..."
    cp /opt/alvr/alvr_config.json "$HOME/.local/share/alvr/session.json" 2>/dev/null || true
fi

# Steam VR environment
export STEAM_VR=1
export STEAM_RUNTIME=1

# Enable VR optimizations
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/radeon_icd.x86_64.json:/usr/share/vulkan/icd.d/intel_icd.x86_64.json

# Start ALVR server in background
gow_log "Starting ALVR server..."
cd /opt/alvr
./alvr_launcher &
ALVR_PID=$!

# Wait a moment for ALVR to initialize
sleep 5

# Start Steam with VR support
gow_log "Starting Steam with VR support..."
export STEAM_STARTUP_FLAGS="-vr -bigpicture"

# Steam environment optimizations
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
export STEAM_USE_MANGOAPP=1
export MANGOHUD_CONFIGFILE=$(mktemp /tmp/mangohud.XXXXXXXX)
export STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT=1
export STEAM_USE_DYNAMIC_VRS=1
export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp /tmp/radv_vrs.XXXXXXXX)

# Start the compositor and Steam
source /opt/gow/launch-comp.sh
launcher /usr/games/steam ${STEAM_STARTUP_FLAGS}
