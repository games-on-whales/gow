echo "Waiting for X11 to be up and running on ${DISPLAY}"
while [ ! xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 ]; do 
    sleep 0.1;
done

pulseaudio #--log-level=4 --log-target=stderr -v