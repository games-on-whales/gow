#!/bin/bash
# Custom steam startup script, the default `steam` script that comes from Fedora was failing

STEAMDIR="${HOME}/.local/share/Steam"
STEAMDIR_LEGACY="${HOME}/.steam/steam"
echo "Steam directory: $STEAMDIR"

if [[ ! -f "$STEAMDIR/steam.sh" ]]; then
    mkdir -p "$STEAMDIR"
    cd "$STEAMDIR"
    tar xJf /usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
fi

# Ensure ~/.steam/steam is a symlink to the real Steam directory.
# Note: do NOT mkdir -p "$STEAMDIR_LEGACY" before this. If the legacy path
# exists as a real directory, `ln -sfn` cannot replace it and silently
# nests the link inside as ".steam/steam/Steam", which then fools the
# migration guard in cont-init/system-services.sh into firing on every boot.
mkdir -p "$(dirname "$STEAMDIR_LEGACY")"
if [ -L "$STEAMDIR_LEGACY" ] || [ ! -e "$STEAMDIR_LEGACY" ]; then
    ln -sfn "$STEAMDIR" "$STEAMDIR_LEGACY"
elif [ -d "$STEAMDIR_LEGACY" ] && [ -z "$(ls -A "$STEAMDIR_LEGACY" 2>/dev/null)" ]; then
    rmdir "$STEAMDIR_LEGACY" && ln -sfn "$STEAMDIR" "$STEAMDIR_LEGACY"
else
    echo "WARN: $STEAMDIR_LEGACY is a non-empty real directory; refusing to replace with symlink. Manual cleanup required."
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