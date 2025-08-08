#!/bin/bash
# Build script for VR containers

set -e

YOUR_REGISTRY="ghcr.io/devilblader87/gow"

echo "🎮 Building VR streaming container..."
echo "Registry: $YOUR_REGISTRY"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker not found in this environment"
    echo ""
    echo "✅ No problem! Your containers will be built automatically via GitHub Actions"
    echo ""
    echo "To trigger automatic builds:"
    echo "1. git add ."
    echo "2. git commit -m 'Add VR support'"
    echo "3. git push origin main"
    echo "4. Check build status: https://github.com/Devilblader87/gow/actions"
    echo ""
    echo "Your VR container will be available at:"
    echo "  $YOUR_REGISTRY/vr-steamvr:edge"
    exit 0
fi

# Check if we're in the right directory
if [ ! -d "apps/vr-steamvr/build" ]; then
    echo "❌ Error: VR container directory not found"
    echo "Expected: apps/vr-steamvr/build/"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Build the VR container
echo "🏗️  Building VR SteamVR container..."
cd apps/vr-steamvr/build

# Try to pull base image first
echo "📥 Pulling base image..."
docker pull ghcr.io/games-on-whales/base-app:edge || {
    echo "⚠️  Could not pull base image - will use local if available"
}

# Build the container
docker build -t "$YOUR_REGISTRY/vr-steamvr:edge" \
  --build-arg BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge \
  . || {
    echo "❌ Build failed!"
    echo ""
    echo "Common solutions:"
    echo "1. Check Dockerfile syntax"
    echo "2. Ensure base image is available"
    echo "3. Check Docker daemon is running"
    exit 1
}

echo "✅ VR SteamVR container built successfully!"
echo ""
echo "🏷️  Container tagged as: $YOUR_REGISTRY/vr-steamvr:edge"

# Test the container
echo "🧪 Testing container..."
if docker run --rm "$YOUR_REGISTRY/vr-steamvr:edge" echo "Container test successful"; then
    echo "✅ Container test passed"
else
    echo "⚠️  Container test failed - but container was built"
fi

# Optional: Push to registry
echo ""
echo "📤 Push to GitHub Container Registry? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🔐 Pushing to $YOUR_REGISTRY..."
    
    # Check if logged in
    if docker push "$YOUR_REGISTRY/vr-steamvr:edge"; then
        echo "✅ Container pushed successfully!"
        echo "🌐 Available at: https://github.com/users/Devilblader87/packages"
    else
        echo "❌ Push failed - you may need to login:"
        echo "echo \$GITHUB_TOKEN | docker login ghcr.io -u Devilblader87 --password-stdin"
    fi
else
    echo "ℹ️  Container built locally only"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Update Wolf config: ../../../bin/update-config.sh"
echo "2. Restart Wolf server"
echo "3. Connect via Moonlight to 'VR Streaming' app"
echo "4. Configure ALVR at http://YOUR_SERVER_IP:8082"
echo "5. Connect Quest 3 and start VR gaming!"
echo ""
echo "📚 See VR_SETUP_GUIDE.md for detailed setup instructions"
