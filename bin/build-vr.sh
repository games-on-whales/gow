#!/bin/bash
# Build script for VR containers

set -e

echo "Building VR streaming containers..."

# Build the full VR + SteamVR container
echo "Building VR SteamVR container..."
cd apps/vr-steamvr/build
docker build -t ghcr.io/games-on-whales/vr-steamvr:edge .

echo "✅ VR SteamVR container built successfully!"

# Optional: Build simple ALVR-only container
echo "Would you like to build a simple ALVR-only container? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Building simple ALVR container..."
    # This would need a separate Dockerfile for just ALVR
    echo "ℹ️  Simple ALVR container requires separate Dockerfile"
fi

echo "🎮 VR containers ready!"
echo ""
echo "Next steps:"
echo "1. Start Wolf server"
echo "2. Connect via Moonlight to 'VR Streaming' app"
echo "3. Install ALVR client on your Quest 3"
echo "4. Visit http://YOUR_SERVER_IP:8082 to configure"
echo "5. Start VR gaming!"
