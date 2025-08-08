#!/bin/bash
# Complete setup script for GOW with VR support

set -e

echo "🎮 Games on Whales - Complete Setup with VR Support"
echo "===================================================="
echo ""

# Check if we're in the right directory
if [ ! -f "BUILD_GUIDE.md" ]; then
    echo "❌ Error: Run this script from the root of your gow repository"
    echo "Current directory: $(pwd)"
    echo "Expected files: BUILD_GUIDE.md, apps/, bin/"
    exit 1
fi

echo "✅ Repository structure confirmed"

# Make all scripts executable
echo "🔧 Making scripts executable..."
find bin/ -name "*.sh" -exec chmod +x {} \;

# Check Git repository
echo "📊 Checking Git repository status..."
if git status >/dev/null 2>&1; then
    echo "✅ Git repository found"
    
    REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "unknown")
    echo "📍 Repository: $REPO_URL"
    
    if [[ "$REPO_URL" == *"Devilblader87/gow"* ]]; then
        echo "✅ Correct repository detected"
    else
        echo "⚠️  Repository might not be the expected one"
    fi
    
    # Check for uncommitted changes
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "✅ Working directory clean"
    else
        echo "⚠️  You have uncommitted changes - will commit them"
    fi
else
    echo "❌ Not a git repository"
    exit 1
fi

# Check if VR app directory exists
if [ -d "apps/vr-steamvr" ]; then
    echo "✅ VR Streaming app found"
else
    echo "❌ VR Streaming app not found"
    echo "The VR app should be in: apps/vr-steamvr/"
    exit 1
fi

echo ""
echo "🚀 Starting automatic setup..."
echo ""

# Step 1: Add and commit changes
echo "📝 Step 1: Committing changes to Git..."
git add .
git status --porcelain
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "ℹ️  No changes to commit"
else
    git commit -m "Add VR streaming support with ALVR + SteamVR

- Added VR container with ALVR and SteamVR
- Updated Wolf configuration system
- Added build automation scripts
- Enabled root access for VR hardware requirements

Features:
- Quest 3 wireless VR streaming
- SteamVR integration
- Web interface on port 8082
- Automatic container builds via GitHub Actions"
    echo "✅ Changes committed"
fi

# Step 2: Update Wolf configuration
echo ""
echo "🔧 Step 2: Updating Wolf configuration..."
if [ -f "/home/retro/config.toml" ]; then
    ./bin/update-config.sh
else
    echo "⚠️  Wolf config.toml not found at /home/retro/config.toml"
    echo "Will create instructions for manual update"
fi

# Step 3: Show GitHub Actions info
echo ""
echo "🏗️  Step 3: Container Building Instructions"
echo ""
echo "Your containers will be automatically built when you push to GitHub:"
echo ""
echo "To trigger builds now:"
echo "  git push origin main"
echo ""
echo "Monitor build progress:"
echo "  https://github.com/Devilblader87/gow/actions"
echo ""
echo "Your containers will be available at:"
echo "  ghcr.io/devilblader87/gow/vr-steamvr:edge"
echo "  ghcr.io/devilblader87/gow/xfce:edge (with root access)"
echo "  ghcr.io/devilblader87/gow/steam:edge"
echo "  ... and all other apps"

# Step 4: Final instructions
echo ""
echo "🎯 Step 4: What to do next"
echo ""
echo "1. 📤 Push to GitHub (if not done already):"
echo "   git push origin main"
echo ""
echo "2. ⏳ Wait for containers to build (10-20 minutes)"
echo "   Check: https://github.com/Devilblader87/gow/actions"
echo ""
echo "3. 🔄 Restart Wolf server:"
echo "   sudo systemctl restart wolf"
echo "   # or however you run Wolf"
echo ""
echo "4. 🎮 Connect via Moonlight:"
echo "   - Look for 'VR Streaming (ALVR + SteamVR)' in app list"
echo "   - Launch it to start ALVR server"
echo ""
echo "5. 🥽 Set up Quest 3:"
echo "   - Install ALVR client on Quest 3"
echo "   - Connect to same WiFi network"
echo "   - Visit http://YOUR_SERVER_IP:8082 to configure"
echo ""
echo "📚 For detailed guides:"
echo "   - BUILD_GUIDE.md - Container building details"
echo "   - VR_SETUP_GUIDE.md - Complete VR setup walkthrough"
echo ""
echo "🆘 If you need help:"
echo "   - Check GitHub Actions logs for build issues"
echo "   - Verify network connectivity for VR streaming"
echo "   - Ensure GPU drivers are installed"
echo ""
echo "✅ Setup complete! Happy VR gaming! 🎮🥽"
