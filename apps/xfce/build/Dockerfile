# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    lsb-release \
    wget \
    curl \
    gnupg2 \
    dbus-x11 \
    firefox \
    flatpak \
    sudo \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gdebi-core \
    "

ARG DE_PACKAGES=" \
    xfce4 \
    xfce4-settings \
    xubuntu-default-settings \
    xubuntu-icon-theme \
    papirus-icon-theme arc-theme \
    at-spi2-core \
    thunar \
    thunar-volman \
    thunar-archive-plugin \
    thunar-media-tags-plugin \
    "

ARG ADDITIONAL_PACKAGES=" \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-whiskermenu-plugin \
    xfce4-docklike-plugin \
    xfce4-panel-profiles \
    xfce4-places-plugin \
    xarchiver \
    mousepad \
    zip unzip p7zip-full \
    gnome-software gnome-software-plugin-flatpak \
    file-roller \
    gvfs \
    gvfs-backends \
    gvfs-fuse \
    ntfs-3g \
    exfat-fuse \
    fuse \
    git \
    vim \
    nano \
    htop \
    tree \
    "

ARG DEV_PACKAGES=" \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    nodejs \
    npm \
    default-jdk \
    mono-complete \
    dotnet-sdk-8.0 \
    libnss3-dev \
    libatk-bridge2.0-dev \
    libdrm2 \
    libxkbcommon-dev \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libasound2t64 \
    libatspi2.0-0 \
    libgtk-3-0 \
    libxshmfence1 \
    "
# 
# Prevent firefox snap
COPY scripts/ff-unsnap /etc/apt/preferences.d/ff-unsnap

RUN \
    # \
    # Setup repositories \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
    # \
    # Add Firefox PPA \
    add-apt-repository -y ppa:mozillateam/ppa && \
    # \
    # Add Microsoft GPG key and repository for VS Code \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    # \
    # Add Google Chrome repository \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    # \
    # Add Microsoft .NET repository \
    wget -qO- https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    # \
    # Update package lists \
    apt-get update && \
    # \
    # Install core packages \
    apt-get install -y $CORE_PACKAGES && \
    # \
    # Install desktop environment \
    apt-get install -y $DE_PACKAGES

# Install additional packages in separate layer for better caching
RUN apt-get install -y --no-install-recommends $ADDITIONAL_PACKAGES

# Install development packages
RUN apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        python3 \
        python3-pip \
        nodejs \
        npm \
        default-jdk \
        mono-complete \
        libnss3-dev \
        libatk-bridge2.0-dev \
        libdrm2 \
        libxkbcommon-dev \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libxss1 \
        libatspi2.0-0 \
        libgtk-3-0 \
        libxshmfence1 && \
    # Try to install .NET SDK (may fail on some Ubuntu versions) \
    (apt-get install -y dotnet-sdk-8.0 || apt-get install -y dotnet-sdk-6.0 || echo ".NET SDK not available - continuing") && \
    # Try both package names for libasound2 \
    (apt-get install -y libasound2t64 || apt-get install -y libasound2 || echo "Audio library package not found - continuing")

# Install applications
RUN \
    # Install Visual Studio Code \
    apt-get install -y code && \
    # \
    # Install Google Chrome \
    apt-get install -y google-chrome-stable && \
    # \
    # Install Steam \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y steam-installer

# Install Unity Hub and setup applications
RUN \
    # Download and install Unity Hub \
    wget -qO unity-hub.AppImage https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage && \
    chmod +x unity-hub.AppImage && \
    mv unity-hub.AppImage /opt/unity-hub && \
    # \
    # Create Unity Hub desktop entry \
    mkdir -p /usr/share/applications && \
    echo '[Desktop Entry]\n\
Name=Unity Hub\n\
Comment=Unity development environment\n\
Exec=/opt/unity-hub\n\
Icon=unity-hub\n\
Terminal=false\n\
Type=Application\n\
Categories=Development;' > /usr/share/applications/unity-hub.desktop && \
    # \
    # Download Unity Hub icon (allow failure) \
    wget -qO /usr/share/pixmaps/unity-hub.png https://unity.com/favicon.ico || echo "Icon download failed"

# Setup user permissions and directories
RUN \
    # Create fuse group if it doesn't exist and add retro user \
    groupadd -f fuse && \
    usermod -a -G fuse retro && \
    # \
    # Set up Wolf directories with proper permissions \
    mkdir -p /mnt/Wolf/Projects /mnt/Wolf/Unity /mnt/Wolf/Steam /mnt/Wolf/VSCode /mnt/Wolf/Downloads /mnt/Wolf/Documents && \
    mkdir -p /home/retro/Projects /home/retro/Unity /home/retro/Downloads /home/retro/Documents && \
    mkdir -p /shared/projects /shared/unity /shared/downloads /shared/documents && \
    # Create symlinks to Wolf directories \
    ln -sf /mnt/Wolf/Projects /home/retro/Projects && \
    ln -sf /mnt/Wolf/Unity /home/retro/Unity && \
    ln -sf /mnt/Wolf/Downloads /home/retro/Downloads && \
    ln -sf /mnt/Wolf/Documents /home/retro/Documents && \
    # Set permissions \
    chown -R retro:retro /mnt/Wolf && \
    chown -R retro:retro /home/retro && \
    chown -R retro:retro /shared

# Cleanup
RUN \
    # Fixes \
    rm -f /etc/xdg/autostart/xscreensaver.desktop && \
    # \
    # Clean up \
    apt-get remove -y foot software-properties-common gpg-agent && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /config/.cache \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/* \
        packages.microsoft.gpg

# 
# Replace launch scripts
COPY --chmod=777 scripts/launch-comp.sh scripts/startup-enhanced.sh /opt/gow/
COPY --chmod=777 scripts/startup-enhanced.sh /opt/gow/startup.sh
COPY --chmod=777 scripts/startdbus.sh /opt/gow/startdbus
COPY --chmod=755 scripts/root-shell.sh /usr/local/bin/root-shell

#
# Include default xfce config
COPY --chmod=777 --chown=retro:retro scripts/xfce4 /opt/gow/xfce4

# 
# Fix locals
COPY scripts/locale /etc/default/locale

# 
# Allow retro user full sudo access without password
RUN echo "\nretro ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "\nALL ALL=NOPASSWD: /opt/gow/startdbus" >> /etc/sudoers

# 
# Fix bwarp perms for flatpaks
RUN chmod u+s /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

# Enhanced XFCE Development Environment - Build $(date +%Y%m%d)
# Includes Unity Hub, VS Code, Chrome, Steam, and development tools

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
LABEL org.opencontainers.image.title="Enhanced XFCE Development Environment"
LABEL org.opencontainers.image.description="XFCE desktop with Unity Hub, VS Code, Chrome, Steam, and development tools"
