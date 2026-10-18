ARG BASE_APP_IMAGE

######################################
# Patched bubblewrap that works with CAP_SYS_ADMIN in containers (same as the Lutris and Steam images).
# Needed by pressure-vessel when running Battle.net through Proton (umu-run).
FROM ${BASE_APP_IMAGE} AS bwrap-builder

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git meson ca-certificates dpkg-dev && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    ./ci/builddeps.sh && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson _builddir && \
    meson compile -C _builddir

######################################

FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG REQUIRED_PACKAGES=" \
    wget \
    curl \
    git \
    python3 \
    python3-build \
    python3-hatchling \
    python3-installer \
    python3-urllib3 \
    python3-certifi \
    python3-zstandard \
    python3-xlib \
    xvfb \
    x11-utils \
    cabextract \
    ca-certificates \
    gnupg \
    xwayland \
    wl-clipboard \
    xclip \
    xdotool \
    libgl1 \
    libegl1 \
    libvulkan1 \
    libgl1:i386 \
    libglx-mesa0:i386 \
    libgl1-mesa-dri:i386 \
    libegl1:i386 \
    libegl-mesa0:i386 \
    libvulkan1:i386 \
    mesa-vulkan-drivers:i386 \
    "

# Build umu-launcher (runs Proton-GE inside the Steam Linux Runtime, like Lutris does)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    git clone --depth 1 --branch 1.4.4 https://github.com/Open-Wine-Components/umu-launcher.git /tmp/umu && \
    cd /tmp/umu && \
    python3 -m build --wheel --no-isolation && \
    python3 -m installer dist/*.whl && \
    rm -rf /tmp/umu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Proton-GE and the Steam Linux Runtime live in the image so nothing is downloaded at start.
ARG GE_PROTON_VERSION=GE-Proton11-7
ENV XDG_DATA_HOME=/opt/umu-data

# Everything below is owned by an unprivileged build user: umu-run refuses to run as root, and
# not needing a recursive chown/chmod afterwards keeps these multi-GB trees out of a duplicate layer.
RUN useradd -m umubuild && \
    mkdir -p $XDG_DATA_HOME && chown umubuild $XDG_DATA_HOME

# Download Proton-GE (pinned version)
RUN runuser -u umubuild -- sh -c ' \
        mkdir -p $XDG_DATA_HOME/Steam/compatibilitytools.d && \
        URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/tags/'"${GE_PROTON_VERSION}"' \
            | grep browser_download_url | grep "\.tar\.gz" | grep -v aarch64 | head -1 | cut -d\" -f4) && \
        echo "Downloading $URL" && \
        curl -sL "$URL" | tar -xz -C $XDG_DATA_HOME/Steam/compatibilitytools.d/ && \
        ls $XDG_DATA_HOME/Steam/compatibilitytools.d/ && \
        ln -s $(ls -d $XDG_DATA_HOME/Steam/compatibilitytools.d/GE-Proton* | head -1) $XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton'

# Download the Steam Linux Runtime. umu fetches it before launching; the launch itself cannot work
# during a docker build (no CAP_SYS_ADMIN), so only the download is kept.
# Afterwards open up the (non-recursive) directories umu writes lock files to at runtime.
RUN (runuser -u umubuild -- env HOME=/home/umubuild XDG_DATA_HOME=$XDG_DATA_HOME \
        PROTONPATH=$XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton GAMEID=0 \
        WINEPREFIX=/tmp/umu-dummy-prefix umu-run /nonexistent.exe || true) && \
    rm -rf /tmp/umu-dummy-prefix && \
    test -d $XDG_DATA_HOME/umu/steamrt4/pressure-vessel && \
    chmod a+rwx $XDG_DATA_HOME $XDG_DATA_HOME/umu $XDG_DATA_HOME/Steam $XDG_DATA_HOME/Steam/compatibilitytools.d && \
    chmod a+rx $XDG_DATA_HOME/umu/umu-shim && \
    for f in $XDG_DATA_HOME/umu/steamrt4/steamrt4_platform_*/files; do \
        touch $f/.ref && chmod a+rw $f/.ref && chmod a+w $f; \
    done && \
    userdel umubuild

# Host libraries Proton's Wine needs for the build-time prefix and installer run
# (at runtime the Steam Linux Runtime provides these).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6 libfreetype6:i386 \
        libfontconfig1 libfontconfig1:i386 \
        libgnutls30t64 libgnutls30t64:i386 \
        libx11-6 libx11-6:i386 libxext6 libxext6:i386 \
        libxcursor1 libxcursor1:i386 libxrandr2 libxrandr2:i386 \
        libxi6 libxi6:i386 libxcomposite1 libxcomposite1:i386 \
        libxfixes3 libxfixes3:i386 libxrender1 libxrender1:i386 \
        libxinerama1 libxinerama1:i386 \
        libpulse0 libpulse0:i386 libasound2t64 libasound2t64:i386 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the Proton prefix with Proton directly (no pressure-vessel in docker build).
# 'pfx -> .' is the layout umu-run uses when WINEPREFIX is set.
RUN mkdir -p /opt/battlenet /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    ln -s . /opt/battlenet/pfx

RUN Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp & \
    until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.5; done && \
    export HOME=/root DISPLAY=:99 STEAM_COMPAT_DATA_PATH=/opt/battlenet \
        STEAM_COMPAT_CLIENT_INSTALL_PATH=$XDG_DATA_HOME/Steam SteamAppId=0 GAMEID=0 && \
    P=$XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton && \
    python3 $P/proton run wineboot -u && \
    WINEPREFIX=/opt/battlenet $P/files/bin/wineserver -w && \
    python3 $P/proton run reg add 'HKCU\Software\Wine\DXVA2' /v backend /d va /f && \
    WINEPREFIX=/opt/battlenet $P/files/bin/wineserver -w && \
    pkill Xvfb || true && \
    rm -f /tmp/.X99-lock

# Install Battle.net (Agent + Battle.net.exe) into the Proton prefix
RUN Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp & \
    until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.5; done && \
    curl -L "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&id=bnetdesk" \
         -o /tmp/bnet-setup.exe && \
    export HOME=/root DISPLAY=:99 STEAM_COMPAT_DATA_PATH=/opt/battlenet \
        STEAM_COMPAT_CLIENT_INSTALL_PATH=$XDG_DATA_HOME/Steam SteamAppId=0 GAMEID=0 \
        STAGING_SHARED_MEMORY=1 WINEDLLOVERRIDES="locationapi=d" && \
    P=$XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton && \
    python3 $P/proton run /tmp/bnet-setup.exe --lang=enUS --installpath="C:\\Program Files (x86)\\Battle.net" & \
    for i in $(seq 1 120); do \
        AGENT_LOG=$(ls /opt/battlenet/drive_c/ProgramData/Battle.net/Agent/Agent.*/Logs/Agent-*.log 2>/dev/null | head -1) && \
        if [ -n "$AGENT_LOG" ] && \
           grep -q "Request GET /agent" "$AGENT_LOG" 2>/dev/null && \
           grep -q "Request GET /game" "$AGENT_LOG" 2>/dev/null && \
           [ -f "/opt/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net.exe" ]; then \
            echo "Install complete at iteration $i - Battle.net.exe installed!" && break; \
        fi; \
        echo "Waiting... ($i/120)"; \
        sleep 5; \
    done && \
    WINEPREFIX=/opt/battlenet $XDG_DATA_HOME/Steam/compatibilitytools.d/bnet-proton/files/bin/wineserver -k 2>/dev/null || true && \
    pkill Xvfb || true && \
    rm -f /tmp/bnet-setup.exe /tmp/.X99-lock && \
    test -f "/opt/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe" && \
    mkdir -p /opt/battlenet/drive_c/users/steamuser/AppData/Roaming/Battle.net && \
    printf '%s\n' '{' \
      '  "Client": {' \
      '    "GameLaunchWindowBehavior": "2",' \
      '    "GameSearch": { "BackgroundSearch": "true" },' \
      '    "HardwareAcceleration": "true",' \
      '    "Install": { "DownloadLimitNextPatchInBps": "0" },' \
      '    "Sound": { "Enabled": "false" },' \
      '    "Streaming": { "StreamingEnabled": "false" }' \
      '  }' \
      '}' > /opt/battlenet/drive_c/users/steamuser/AppData/Roaming/Battle.net/Battle.net.config && \
    chmod -R a+rX /opt/battlenet
# (Battle.net.config above follows the Lutris installer; HardwareAcceleration is on because DXVK from
# Proton makes the GPU path work, software rendering gives repaint artifacts in the login window.)

# Replace system bwrap with the patched version
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

# pressure-vessel (umu-run) bind-mounts /run/udev; Wolf only creates it when a controller is attached
RUN mkdir -p /run/udev

# Show Sway title bars with close button
RUN sed -i 's/default_border pixel 2/default_border normal 2/' /cfg/sway/config && \
    sed -i 's/default_floating_border pixel 2/default_floating_border normal 2/' /cfg/sway/config

COPY --chmod=755 scripts/20-fix-home-perms.sh /etc/cont-init.d/20-fix-home-perms.sh
COPY --chmod=755 scripts/30-wow-userdata.sh /etc/cont-init.d/30-wow-userdata.sh
COPY --chmod=755 scripts/bnet-paste.sh /opt/gow/bnet-paste.sh
COPY scripts/startup.sh /opt/gow/startup-app.sh
RUN chmod +x /opt/gow/startup-app.sh
