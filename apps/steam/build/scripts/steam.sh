#!/bin/bash
# Custom steam startup script, the default `steam` script that comes from Fedora was failing

STEAMDIR="${$HOME/.local/share}/Steam"
echo "Steam directory: $STEAMDIR"

if [[ ! -f "$STEAMDIR/steam.sh" ]]; then
    mkdir -p "$STEAMDIR"
    cd "$STEAMDIR"
    tar xJf /usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
    mkdir -p ~/.steam
    ln -fns "$STEAMDIR" ~/.steam/steam
fi


cd "$STEAMDIR"

while true; do
    echo "Steam arguments received: $@"
    ./steam.sh "$@"
    EXIT_CODE=$?

    # Exit code 0 means clean shutdown (user quit)
    # Exit codes like 42 or other non-zero often mean "restart me"
    if [[ $EXIT_CODE -eq 0 ]]; then
        echo "Steam exited cleanly"
        break
    fi

    echo "Steam exited with code $EXIT_CODE, restarting in 2 seconds..."
    sleep 2
done