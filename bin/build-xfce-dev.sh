#!/bin/bash
# Build script for Enhanced XFCE Development Container

set -e

YOUR_REGISTRY="ghcr.io/devilblader87/gow"
CONTAINER_NAME="xfce-dev"

echo "🚀 Building Enhanced XFCE Development Container"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "apps/xfce/build/Dockerfile" ]; then
    echo "❌ Error: Run this script from the root of your gow repository"
    exit 1
fi

echo "✅ Repository structure looks good"
echo "📦 Building container: $YOUR_REGISTRY/$CONTAINER_NAME:edge"
echo ""

# Build the container
cd apps/xfce/build
echo "🔧 Building enhanced XFCE with development tools..."
docker build -t "$YOUR_REGISTRY/$CONTAINER_NAME:edge" \
  --build-arg BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge \
  .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Enhanced XFCE container built successfully!"
    echo ""
    echo "📋 Container includes:"
    echo "   🎮 Unity Hub"
    echo "   💻 Visual Studio Code"
    echo "   🌐 Google Chrome"
    echo "   🎮 Steam"
    echo "   📁 Enhanced file manager with full access"
    echo "   🛠️  Development tools (Git, Node.js, Python, .NET)"
    echo ""
else
    echo "❌ Build failed!"
    exit 1
fi

# Optional: Push to registry
echo "Push to registry? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "📤 Pushing to $YOUR_REGISTRY..."
    docker push "$YOUR_REGISTRY/$CONTAINER_NAME:edge"
    echo "✅ Container pushed to registry!"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Update your Wolf configuration:"
echo "   - Change image to: $YOUR_REGISTRY/$CONTAINER_NAME:edge"
echo "   - Add volume mounts for persistent data"
echo ""
echo "2. Restart Wolf server to use new container"
echo ""
echo "3. Connect via Moonlight and enjoy your development environment!"
echo ""
echo "📁 Persistent directories:"
echo "   - Projects: /home/retro/Projects"
echo "   - Unity: /home/retro/Unity"
echo "   - VS Code: /home/retro/.config/Code"
echo "   - Steam: /home/retro/.local/share/Steam"
echo ""
echo "🔧 Development tools ready:"
echo "   - Unity Hub: /opt/unity-hub"
echo "   - VS Code: code command"
echo "   - Chrome: google-chrome-stable"
echo "   - Steam: steam command"
echo ""
echo "Happy developing! 🚀"
