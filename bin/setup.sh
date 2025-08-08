#!/bin/bash
# Quick setup script for your custom GOW repository

set -e

echo "🎮 Games on Whales - Custom Repository Setup"
echo "============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "apps/xfce/assets/wolf.config.toml" ]; then
    echo "❌ Error: Run this script from the root of your gow repository"
    exit 1
fi

echo "✅ Repository structure looks good"

# Check if VR app exists
if [ -d "apps/vr-steamvr" ]; then
    echo "✅ VR Streaming app found"
else
    echo "⚠️  VR Streaming app not found - create it first"
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x bin/*.sh 2>/dev/null || true

# Check Git status
if git status >/dev/null 2>&1; then
    echo "✅ Git repository initialized"
    
    # Check if we have uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  You have uncommitted changes"
        echo "   Run 'git add . && git commit -m \"Your message\"' to commit them"
    else
        echo "✅ Working directory clean"
    fi
else
    echo "❌ Not a git repository or git not available"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Build your containers:"
echo "   git add ."
echo "   git commit -m \"Add VR support and custom containers\""
echo "   git push origin main"
echo ""
echo "2. Wait for GitHub Actions to build containers"
echo "   Check: https://github.com/Devilblader87/gow/actions"
echo ""
echo "3. Update your Wolf configuration:"
echo "   ./bin/update-wolf-config.sh"
echo ""
echo "4. Add VR app to Wolf:"
echo "   cat VR_APP_CONFIG.toml >> /home/retro/config.toml"
echo ""
echo "5. Restart Wolf and enjoy VR gaming!"
echo ""
echo "📚 For detailed instructions, see BUILD_GUIDE.md"
echo "🆘 For VR setup, see VR_SETUP_GUIDE.md"
