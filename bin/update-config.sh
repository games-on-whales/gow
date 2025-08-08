#!/bin/bash
# Script to update your Wolf config.toml to use your custom containers and add VR support

set -e

CONFIG_FILE="/home/retro/config.toml"
BACKUP_FILE="/home/retro/config.toml.backup.$(date +%Y%m%d_%H%M%S)"
YOUR_REGISTRY="ghcr.io/devilblader87/gow"

echo "🔧 Updating Wolf configuration..."
echo "Config file: $CONFIG_FILE"
echo "Your registry: $YOUR_REGISTRY"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Config file not found: $CONFIG_FILE"
    echo "Make sure Wolf is running and config.toml exists"
    exit 1
fi

# Create backup
echo "📋 Creating backup: $BACKUP_FILE"
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Update all image references to use your registry
echo "🔄 Updating container images to use your registry..."
sed -i "s|ghcr.io/games-on-whales/|${YOUR_REGISTRY}/|g" "$CONFIG_FILE"

# Check if VR app already exists
if grep -q "VR Streaming" "$CONFIG_FILE"; then
    echo "⚠️  VR Streaming app already exists in config - skipping"
else
    echo "➕ Adding VR Streaming app..."
    
    # Add VR app configuration
    cat >> "$CONFIG_FILE" << 'EOF'

[[apps]]
title = 'VR Streaming (ALVR + SteamVR)'
icon_png_path = "https://games-on-whales.github.io/wildlife/apps/vr-steamvr/assets/icon.png"
start_virtual_compositor = true

[apps.runner]
type = 'docker'
name = 'WolfVRStreaming'
image = 'ghcr.io/devilblader87/gow/vr-steamvr:edge'
env = [
    'GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*',
    'ALVR_SERVER_HOST=0.0.0.0',
    'ALVR_WEB_PORT=8082',
    'STEAM_VR=1',
    'RUN_SWAY=true'
]
devices = []
mounts = [
    'alvr-data:/home/retro/.local/share/alvr:rw',
    'steamvr-data:/home/retro/.steam:rw'
]
ports = [
    '8082:8082/tcp',
    '9943:9943/udp',
    '9944:9944/udp'
]
base_create_json = """
{
  "HostConfig": {
    "IpcMode": "host",
    "Privileged": true,
    "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
    "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
    "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
  },
  "User": "0:0"
}
"""
EOF
fi

echo ""
echo "✅ Configuration updated successfully!"
echo ""
echo "📊 Summary of changes:"
echo "  - Updated all containers to use: $YOUR_REGISTRY"
echo "  - Added VR Streaming app (ALVR + SteamVR)"
echo "  - Enabled root access and full privileges"
echo "  - Configured ports: 8082 (web), 9943-9944 (streaming)"
echo ""
echo "🔄 Your containers now point to:"
grep "image = " "$CONFIG_FILE" | head -5
echo "  ... and more"
echo ""
echo "🚀 Next steps:"
echo "1. Push your changes to GitHub to build containers:"
echo "   git add . && git commit -m 'Add VR support' && git push"
echo ""
echo "2. Wait for GitHub Actions to build containers:"
echo "   https://github.com/Devilblader87/gow/actions"
echo ""
echo "3. Restart Wolf server to load new config"
echo ""
echo "4. Connect via Moonlight and look for 'VR Streaming' app"
echo ""
echo "💡 Backup created at: $BACKUP_FILE"
echo "💡 To revert: cp '$BACKUP_FILE' '$CONFIG_FILE'"
