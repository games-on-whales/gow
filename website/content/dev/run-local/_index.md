---
title: 'Run locally'
---

# Run an image locally

If you have a desktop environment running on your host, you can run the built image without even using Wolf.  
Here's an example of running Steam inside Docker *on a Wayland host* without installing anything else on your host:

```bash
docker run --name=steam --rm -it \
--device=/dev/dri/renderD128 \
--device=/dev/dri/card0 \
--ipc=host \
--cap-add=ALL \
--security-opt seccomp=unconfined \
-e XDG_RUNTIME_DIR=/tmp \
-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:/tmp/${WAYLAND_DISPLAY}:rw \
-e XDG_SESSION_TYPE=wayland \
-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
-e RUN_SWAY=true \
-v /tmp/SteamGOWData:/home/retro/ \
ghcr.io/games-on-whales/steam:edge
```

{{% figure
src=steam-on-desktop.png
alt="Screenshot of Steam running on a desktop environment"
caption="The Steam big picture mode should start on your host in a normal window" %}}

{{% hint info %}}
**Note:**

Depending on your host setup, you might need to adjust this command.  
For example, for *Nvidia users* with the container toolkit installed you might need to add `--gpus=all` instead of
`--device=/dev/dri/renderD128 --device=/dev/dri/card0` and `-e NVIDIA_DRIVER_CAPABILITIES=all` to the environment
variables.

In the command above `/tmp/SteamGOWData` in your host is where the home folder (containing Steam client and settings in
this example) will be stored, make sure to adjust that to your liking.

{{% /hint %}}