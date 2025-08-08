#!/bin/bash
# Enhanced XFCE startup script with development applications

set -e
source /opt/gow/bash-lib/utils.sh

gow_log "[XFCE] Enhanced startup with development tools"

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

# Set up user directories and Wolf data directories
gow_log "[XFCE] Setting up Wolf data directories"
mkdir -p "/mnt/Wolf/Projects" "/mnt/Wolf/Unity" "/mnt/Wolf/Downloads" "/mnt/Wolf/Documents" "/mnt/Wolf/VSCode" "/mnt/Wolf/Steam"
mkdir -p "$HOME/.config/Code/User"
mkdir -p "$HOME/.local/share/Steam"

# Configure VS Code to use Wolf directory for settings
mkdir -p "/mnt/Wolf/VSCode/User"
if [ ! -f "/mnt/Wolf/VSCode/User/settings.json" ]; then
    gow_log "[XFCE] Configuring VS Code with Wolf directory"
    cat > "/mnt/Wolf/VSCode/User/settings.json" << 'EOF'
{
    "telemetry.telemetryLevel": "off",
    "update.mode": "manual",
    "extensions.autoUpdate": false,
    "workbench.startupEditor": "welcomePage",
    "files.autoSave": "afterDelay",
    "editor.fontSize": 14,
    "terminal.integrated.fontSize": 12,
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "extensions.autoCheckUpdates": false
}
EOF
fi

# Link VS Code config to Wolf directory
ln -sf "/mnt/Wolf/VSCode/User" "$HOME/.config/Code/User"

# Configure Steam to use Wolf directory
mkdir -p "/mnt/Wolf/Steam"
if [ ! -d "$HOME/.local/share/Steam" ]; then
    ln -sf "/mnt/Wolf/Steam" "$HOME/.local/share/Steam"
fi

# Create desktop shortcuts
gow_log "[XFCE] Creating desktop shortcuts"
mkdir -p "$HOME/Desktop"

# Unity Hub shortcut
cat > "$HOME/Desktop/Unity Hub.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Unity Hub
Comment=Unity development environment
Exec=/opt/unity-hub
Icon=unity-hub
Terminal=false
Categories=Development;
EOF

# VS Code shortcut
cat > "$HOME/Desktop/Visual Studio Code.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Visual Studio Code
Comment=Code Editor
Exec=code
Icon=vscode
Terminal=false
Categories=Development;TextEditor;
EOF

# Chrome shortcut
cat > "$HOME/Desktop/Google Chrome.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Comment=Web Browser
Exec=google-chrome-stable
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
EOF

# Steam shortcut
cat > "$HOME/Desktop/Steam.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Steam
Comment=Gaming Platform
Exec=steam
Icon=steam
Terminal=false
Categories=Game;
EOF

# Make desktop shortcuts executable
chmod +x "$HOME/Desktop"/*.desktop

# Configure environment variables for Wolf directories
gow_log "[XFCE] Setting up Wolf environment variables"
cat >> "$HOME/.bashrc" << 'EOF'

# Wolf Development Environment
export WOLF_DATA="/mnt/Wolf"
export UNITY_PROJECTS_PATH="/mnt/Wolf/Unity"
export CODE_PROJECTS_PATH="/mnt/Wolf/Projects"
export DOWNLOADS_PATH="/mnt/Wolf/Downloads"
export DOCUMENTS_PATH="/mnt/Wolf/Documents"

# Unity Hub configuration
export UNITY_HUB_DATA_DIR="/mnt/Wolf/Unity/Hub"
export UNITY_EDITOR_PATH="/mnt/Wolf/Unity/Editors"

# VS Code configuration
export VSCODE_EXTENSIONS="/mnt/Wolf/VSCode/extensions"
export VSCODE_USER_DATA_DIR="/mnt/Wolf/VSCode"

# Steam configuration
export STEAM_ROOT="/mnt/Wolf/Steam"

# Development aliases
alias projects="cd /mnt/Wolf/Projects"
alias unity="cd /mnt/Wolf/Unity"
alias downloads="cd /mnt/Wolf/Downloads"
alias code-projects="code /mnt/Wolf/Projects"
EOF

# Configure XFCE panels and desktop
gow_log "[XFCE] Configuring XFCE desktop"
if [ -d /opt/gow/xfce4 ]; then
    cp -r /opt/gow/xfce4 "$HOME/.config/"
    chown -R retro:retro "$HOME/.config/xfce4"
fi

# Set up file associations
gow_log "[XFCE] Setting up file associations"
mkdir -p "$HOME/.config/mimeapps"
cat > "$HOME/.config/mimeapps/mimeapps.list" << 'EOF'
[Default Applications]
text/plain=code.desktop
application/json=code.desktop
text/x-csrc=code.desktop
text/x-c++src=code.desktop
text/x-python=code.desktop
text/html=google-chrome.desktop
application/pdf=firefox.desktop
application/zip=org.xfce.Thunar.desktop
inode/directory=org.xfce.Thunar.desktop
EOF

# Configure Thunar (file manager) for better permissions
gow_log "[XFCE] Configuring file manager"
mkdir -p "$HOME/.config/Thunar"
cat > "$HOME/.config/Thunar/thunarrc" << 'EOF'
[Configuration]
DefaultView=ThunarIconView
LastCompactViewZoomLevel=THUNAR_ZOOM_LEVEL_SMALL
LastDetailsViewColumnOrder=THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_DATE_MODIFIED
LastDetailsViewColumnWidths=50,50,50,50
LastDetailsViewFixedColumns=FALSE
LastDetailsViewVisibleColumns=THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE
LastDetailsViewZoomLevel=THUNAR_ZOOM_LEVEL_SMALLER
LastIconViewZoomLevel=THUNAR_ZOOM_LEVEL_NORMAL
LastLocationBar=ThunarLocationButtons
LastSeparatorPosition=170
LastShowHidden=TRUE
LastSidePane=ThunarShortcutsPane
LastSortColumn=THUNAR_COLUMN_NAME
LastSortOrder=GTK_SORT_ASCENDING
LastStatusbarVisible=TRUE
LastView=ThunarIconView
LastWindowHeight=480
LastWindowWidth=640
LastWindowMaximized=FALSE
MiscVolumeManagement=TRUE
MiscCaseSensitive=FALSE
MiscDateStyle=THUNAR_DATE_STYLE_SIMPLE
MiscFoldersFirst=TRUE
MiscHorizontalWheelNavigates=FALSE
MiscRecursivePermissions=THUNAR_RECURSIVE_PERMISSIONS_ASK
MiscRememberGeometry=TRUE
MiscShowAboutTemplates=TRUE
MiscShowThumbnails=TRUE
MiscSingleClick=FALSE
MiscSingleClickTimeout=500
MiscTextBesideIcons=FALSE
EOF

# Set environment variables for development
gow_log "[XFCE] Setting up development environment"
cat >> "$HOME/.bashrc" << 'EOF'

# Development environment variables
export UNITY_HUB_HOME="$HOME/Unity"
export PROJECTS_HOME="$HOME/Projects"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1

# Add custom paths
export PATH="$PATH:$HOME/.local/bin"

# Aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias unity-hub='/opt/unity-hub'
alias projects='cd $PROJECTS_HOME'
alias unity='cd $UNITY_HUB_HOME'
EOF

# Fix ownership
chown -R retro:retro "$HOME"

gow_log "[XFCE] Starting XFCE with enhanced applications"

# Start XFCE
source /opt/gow/launch-comp.sh
launcher
