#!/bin/bash
# Script to update Wolf config to use your custom containers

set -e

CONFIG_FILE="/home/retro/config.toml"
BACKUP_FILE="/home/retro/config.toml.backup"
YOUR_REGISTRY="ghcr.io/devilblader87/gow"

echo "🔧 Updating Wolf configuration to use your custom containers..."

# Create backup
if [ -f "$CONFIG_FILE" ]; then
    echo "📋 Creating backup: $BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
else
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "Make sure Wolf is running and config.toml exists"
    exit 1
fi

# Function to update image references
update_images() {
    local file="$1"
    
    echo "🔄 Updating container images to use $YOUR_REGISTRY..."
    
    # Update all existing app images
    sed -i "s|ghcr.io/games-on-whales/|${YOUR_REGISTRY}/|g" "$file"
    
    echo "✅ Updated container registry references"
}

# Update the config file
update_images "$CONFIG_FILE"

echo ""
echo "🎉 Configuration updated successfully!"
echo ""
echo "Your apps now use:"
echo "- xfce: $YOUR_REGISTRY/xfce:edge"
echo "- steam: $YOUR_REGISTRY/steam:edge"
echo "- firefox: $YOUR_REGISTRY/firefox:edge"
echo "- vr-steamvr: $YOUR_REGISTRY/vr-steamvr:edge (when built)"
echo "- And all other apps..."
echo ""
echo "Next steps:"
echo "1. Push your changes to GitHub to trigger automatic builds"
echo "2. Wait for containers to build (check Actions tab)"
echo "3. Restart Wolf to use new containers"
echo ""
echo "💡 To revert changes: cp $BACKUP_FILE $CONFIG_FILE"
