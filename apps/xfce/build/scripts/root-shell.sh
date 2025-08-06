#!/bin/bash
# Script to launch a root shell from XFCE desktop
# Usage: Run this from a terminal to get root access

if [ "$EUID" -eq 0 ]; then
    echo "Already running as root"
    exec /bin/bash
else
    echo "Switching to root shell..."
    sudo -i
fi
