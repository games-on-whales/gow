ARG BASE_APP_IMAGE

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
    cabextract \
    ca-certificates \
    gnupg \
    xwayland \
    wl-clipboard \
    "

# Install Wine Staging and dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -qO- https://dl.winehq.org/wine-builds/winehq.key | \
        gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key && \
    . /etc/os-release && \
    echo "deb [arch=amd64,i386 signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ ${VERSION_CODENAME} main" \
        > /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-staging && \
    git clone --depth 1 --branch 1.4.4 https://github.com/Open-Wine-Components/umu-launcher.git /tmp/umu && \
    cd /tmp/umu && \
    python3 -m build --wheel --no-isolation && \
    python3 -m installer dist/*.whl && \
    rm -rf /tmp/umu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Initialize Wine prefix and replace wintrust.dll with Proton-GE version
RUN mkdir -p /opt/battlenet /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

RUN Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp & \
    until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.5; done && \
    HOME=/root DISPLAY=:99 WINEPREFIX=/opt/battlenet WINEARCH=win64 WINEDEBUG=-all \
    WINEDLLOVERRIDES="mscoree,mshtml=" wine wineboot && \
    /opt/wine-staging/bin/wineserver -w && \
    LATEST=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep browser_download_url | grep "\.tar\.gz" | grep -v aarch64 | head -1 | cut -d\" -f4) && \
    echo "Extracting wintrust.dll from $LATEST" && \
    mkdir -p /tmp/proton-extract && \
    curl -sL "$LATEST" | tar -xz -C /tmp/proton-extract/ \
        --wildcards "*/lib/wine/x86_64-windows/wintrust.dll" \
                   "*/lib/wine/i386-windows/wintrust.dll" 2>/dev/null || true && \
    find /tmp/proton-extract -path "*/x86_64-windows/wintrust.dll" -exec \
        cp {} /opt/battlenet/drive_c/windows/system32/wintrust.dll \; && \
    find /tmp/proton-extract -path "*/i386-windows/wintrust.dll" -exec \
        cp {} /opt/battlenet/drive_c/windows/syswow64/wintrust.dll \; && \
    rm -rf /tmp/proton-extract && \
    pkill Xvfb || true && \
    rm -f /tmp/.X99-lock

# Install Battle.net (Agent + Battle.net.exe)
RUN Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp & \
    until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.5; done && \
    curl -L "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&id=bnetdesk" \
         -o /tmp/bnet-setup.exe && \
    HOME=/root DISPLAY=:99 WINEPREFIX=/opt/battlenet WINEDEBUG=-all \
    WINE_SIMULATE_WRITECOPY=1 WINEFSYNC=1 \
    WINEDLLOVERRIDES="mscoree,mshtml=,wintrust=n" \
    wine /tmp/bnet-setup.exe --lang=enUS --installpath="C:\\Program Files (x86)\\Battle.net" & \
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
    /opt/wine-staging/bin/wineserver -k 2>/dev/null || true && \
    pkill Xvfb || true && \
    rm -f /tmp/bnet-setup.exe /tmp/.X99-lock && \
    chown -R 1000:1000 /opt/battlenet

# Show Sway title bars with close button
RUN sed -i 's/default_border pixel 2/default_border normal 2/' /cfg/sway/config && \
    sed -i 's/default_floating_border pixel 2/default_floating_border normal 2/' /cfg/sway/config

# Disable Wine crash dialog
RUN rm -f /opt/wine-staging/bin/winedbg \
         /opt/wine-staging/lib/wine/x86_64-windows/winedbg.exe \
         /opt/wine-staging/lib/wine/i386-windows/winedbg.exe

COPY scripts/startup.sh /opt/gow/startup-app.sh
RUN chmod +x /opt/gow/startup-app.sh
