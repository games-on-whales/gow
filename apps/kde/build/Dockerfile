FROM archlinux:latest

# Update system and install Plasma 6, UI dependencies, Discover, Nvidia GPU packages, and core applications
RUN pacman -Syu --noconfirm --needed \
    plasma-desktop \
    plasma-workspace \
    plasma-integration \
    plasma-browser-integration \
    plasma-pa \
    plasma-nm \
    plasma5support \
    kwin \
    kglobalaccel \
    kwallet \
    kde-cli-tools \
    kde-gtk-config \
    kinfocenter \
    discover \
    archlinux-appstream-data \
    flatpak \
    xorg-xwayland \
    xorg-xrdb \
    qt6-wayland \
    qt6-svg \
    breeze \
    breeze-gtk \
    breeze-icons \
    hicolor-icon-theme \
    kirigami \
    layer-shell-qt \
    firefox \
    networkmanager \
    polkit \
    polkit-kde-agent \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts-emoji \
    dbus \
    sudo \
    libglvnd \
    egl-wayland \
    mesa \
    nvidia-utils \
    vulkan-icd-loader \
    xdg-user-dirs \
    xdg-utils \
    xdg-desktop-portal \
    xdg-desktop-portal-kde \
    dolphin \
    konsole \
    systemsettings \
    powerdevil \
    pipewire \
    pipewire-pulse \
    wireplumber \
    shared-mime-info \
    desktop-file-utils \
    gnome-menus \
    ark \
    okular \
    gwenview \
    kate \
    kcalc \
    spectacle \
    && pacman -Scc --noconfirm

# CRITICAL FIX: Plasma 6 uses plasma-applications.menu
RUN mkdir -p /etc/xdg/menus && \
    ln -sf /etc/xdg/menus/plasma-applications.menu /etc/xdg/menus/applications.menu

# TRUE HOST ISOLATION: Physically delete KDE crash handlers from the container.
RUN rm -rf /usr/lib/drkonqi /usr/libexec/drkonqi /usr/bin/drkonqi 2>/dev/null || true

# Force update MIME and Desktop databases
RUN update-mime-database /usr/share/mime && \
    update-desktop-database -q /usr/share/applications && \
    gtk-update-icon-cache -f /usr/share/icons/breeze 2>/dev/null || true && \
    gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true

# Force NetworkManager to manage the docker eth0 interface
RUN mkdir -p /etc/NetworkManager/conf.d && \
    printf "[device]\nmanaged=true\n" > /etc/NetworkManager/conf.d/10-managed.conf

# Force Firefox to use system titlebars
RUN mkdir -p /usr/lib/firefox/defaults/pref && \
    printf 'pref("widget.use-system-titlebar", true);\n' > /usr/lib/firefox/defaults/pref/00-titlebar.js

# Allow retro user to authenticate with polkit without a password
RUN mkdir -p /etc/polkit-1/rules.d && \
    printf 'polkit.addRule(function(action, subject) {\n if (subject.user == "retro") { return polkit.Result.YES; }\n});\n' > /etc/polkit-1/rules.d/10-retro.rules

# INSTANT APP LOAD FIX: Create a dummy systemd1 dbus service that FAILS INSTANTLY.
# This prevents D-Bus from hanging for 25 seconds when you try to open an app.
RUN mkdir -p /usr/share/dbus-1/services && \
    printf "[D-BUS Service]\nName=org.freedesktop.systemd1\nExec=/bin/false\n" > /usr/share/dbus-1/services/org.freedesktop.systemd1.service

# Generate D-Bus machine ID
RUN dbus-uuidgen > /etc/machine-id && \
    mkdir -p /var/lib/dbus && \
    ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Create render and audio groups, create retro user, and set default password and sudo privileges
RUN groupadd -f render && groupadd -f audio && \
    useradd -m -u 1000 -G video,render,audio,wheel -s /bin/bash retro && \
    echo "retro:retro" | chpasswd && \
    echo "retro ALL=(ALL) ALL" > /etc/sudoers.d/retro && \
    chmod 0440 /etc/sudoers.d/retro

# Copy the startup script into the container and make it executable
COPY scripts/startup.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]