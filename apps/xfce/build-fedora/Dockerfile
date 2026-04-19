# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# NOTE: do not insert `# ... \` comments between continued lines — bash treats
# them as a comment that swallows the continuation, which breaks `dnf install`.
RUN dnf install -y \
        wget \
        dbus-x11 \
        flatpak \
        sudo \
        @xfce-desktop-environment \
        xfce4-settings \
        papirus-icon-theme arc-theme \
        at-spi2-core \
        xfce4-terminal \
        xfce4-taskmanager \
        xfce4-whiskermenu-plugin \
        xfce4-docklike-plugin \
        xarchiver \
        mousepad \
        zip unzip p7zip \
        gnome-software \
        dconf \
        firefox \
    && { dnf remove -y foot 2>/dev/null || true; } \
    && rm -f /etc/xdg/autostart/xscreensaver.desktop \
    && dnf clean all

# The xfce-polkit authentication agent (pulled in by @xfce-desktop-environment)
# calls polkit_unix_session_new_for_process_sync() at startup, which requires
# systemd-logind. The Fedora image runs as a plain PID-1 entrypoint — no
# logind — so xfce-polkit dies with:
#   CRITICAL: polkit_agent_listener_register_with_options:
#            assertion 'POLKIT_IS_SUBJECT (subject)' failed
# and XFCE shows a user-visible "PolicyKitAgent" error dialog. Wolf streaming
# doesn't need interactive privilege prompts, so suppress the autostart.
RUN printf '\nHidden=true\n' >> /etc/xdg/autostart/xfce-polkit.desktop

# Register Flathub as a system remote and pre-seed AppStream metadata so
# gnome-software surfaces flatpak apps on first launch (without this the
# Software manager only shows rpm results and hides flathub entirely).
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
    && flatpak remote-modify --enable flathub \
    && flatpak --system update --appstream --noninteractive || true

# Make gnome-software prefer flatpak over rpm for app installs.
RUN mkdir -p /etc/dconf/db/local.d /etc/dconf/profile \
    && printf 'user-db:user\nsystem-db:local\n' > /etc/dconf/profile/user \
    && printf "[org/gnome/software]\npackaging-format-preference=['flatpak', 'rpm']\n" \
        > /etc/dconf/db/local.d/00-gnome-software-prefer-flatpak \
    && dconf update

# Replace launch scripts
COPY --chmod=777 scripts/launch-comp.sh scripts/startup.sh /opt/gow/
COPY --chmod=777 scripts/startdbus.sh /opt/gow/startdbus

# Include default xfce config
COPY --chmod=777 --chown=retro:retro scripts/xfce4 /opt/gow/xfce4

# Fix locales
COPY scripts/locale /etc/default/locale

# Allow anyone to start dbus without password
RUN echo -e "\nALL ALL=NOPASSWD: /opt/gow/startdbus" >> /etc/sudoers

# Fix bwrap perms for flatpaks
RUN chmod u+s /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
