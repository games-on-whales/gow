#!/bin/bash
# Script to apply root access to all Wolf apps

echo "Applying root access configuration to all Wolf apps..."

# List of apps to modify
APPS=(
    "firefox"
    "heroic-games-launcher" 
    "lutris"
    "pegasus"
    "prismlauncher"
    "retroarch"
    "steam"
    "es-de"
)

for app in "${APPS[@]}"; do
    config_file="apps/${app}/assets/wolf.config.toml"
    
    if [ -f "$config_file" ]; then
        echo "Modifying $config_file..."
        
        # Backup original
        cp "$config_file" "$config_file.backup"
        
        # Apply root access configuration
        sed -i 's/"Privileged": false/"Privileged": true/' "$config_file"
        sed -i '/CapAdd.*NET_ADMIN/c\    "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],' "$config_file"
        sed -i '/DeviceCgroupRules/a\    "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],' "$config_file"
        sed -i '/HostConfig.*{/a\  },' "$config_file"
        sed -i '/HostConfig.*{/a\  "User": "0:0",' "$config_file"
        
        echo "✓ Updated $app"
    else
        echo "⚠ Config file not found: $config_file"
    fi
done

echo "Done! All apps now have root access configured."
echo "Note: Changes will take effect on next container creation."
