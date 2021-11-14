---
layout: default
title: Debian/Ubuntu
parent: Desktop environment
nav_order: 1
---

# Debian/Ubuntu

When you already have a desktop environment you can still run our docker containers alongside normal desktop applications.

<figure class="image">
  <img src="{{ '/assets/img/GOW-ubnt-de.png' | relative_url}}" alt="Screenshot on Ubuntu 20.04">
  <figcaption class="text-center">Can you tell that Steam is runnning in Docker?</figcaption>
</figure>


## How it works

You can easily run Sunshine and Steam on Docker without having to install a single package on your desktop! We all know [how catastrophic that can be](https://youtu.be/0506yDSgU7M?t=619).
The idea is to use Xorg and PulseAudio from the host OS and mount only the sockets to the Docker containers.  


> ⚠️ In order for Sunshine to stream your desktop you have to **have a monitor plugged** (or use a dummy plug) and **a user logged in** (or enable [autologin](https://help.ubuntu.com/community/AutoLogin)). 

Getting a working configuration should be fairly straightforward:
 - From the default `docker-compose.yml` comment out `xorg`, `pulse` and `udevd` containers.
 - Update the `.env` file and set the right `XORG_SOCKET`, `PULSE_SOCKET_HOST` and `UDEVD_NETWORK` based on your host.

## Full configuration

This has been tested on Ubuntu 20.04 LTS you might need to tweak the socket locations or `XORG_DISPLAY` based on your system.


### `.env`

```conf
local_state=./local_state

####################
# Needed for MIT-SHM, removing this should cause a performance hit see https://github.com/jessfraz/dockerfiles/issues/359
# Use 'service:xorg' if running on a recent enough docker-compose version
# Use 'host' if your Docker version can't support the service format
SHARED_IPC=host
SHM_SIZE=500M
# Use 'shareable' with service:xorg
# Use 'host' with 'host'
XORG_IPC=host
# Change this if you want to run it on an actual desktop environment
XORG_SOCKET=/tmp/.X11-unix
XORG_DISPLAY=:0

####################
# Using network in order to connect to pulse
# if you do have a pulse server already point this to the pulse socket like unix:/tmp/pulse-sock
# and mount the host socket to the instance
PULSE_SERVER=unix:/tmp/pulse/native
PULSE_SOCKET_HOST=/run/user/1000/pulse/
PULSE_SOCKET_GUEST=/tmp/pulse/

####################
# Nvidia configs
# Set to nvidia if using nvidia-docker
DOCKER_RUNTIME=
GPU_UUID=all

####################
# Set to debug or verbose if you need
SUNSHINE_LOG_LEVEL=info
# Username and password for the web-ui at https://xxx.xxx.xxx.xxx:47990
SUNSHINE_USER=admin
SUNSHINE_PASS=admin

####################
# Services that use udev in order to get devices
# needs to be on the same network
# This is because they need the udev PF_NETLINK socket
UDEVD_NETWORK=host

####################
# Avahi
# if your system already runs avahi-daemon just mount host /run/dbus into Sunshine
# TODO: create avahi docker image instead
DBUS=/run/dbus
```

### `docker-compose.yml`

```yaml
version: "3"

services:

  ####################
  sunshine:
    build: 
      context: ./images/
      dockerfile: sunshine/Dockerfile
      # Uncomment the following to override the default sunshine version
      # args:
      #  BUILD_TYPE: RELEASE # To debug run a console inside then gdb -args sunshine > r > on exception: bt
      #  SUNSHINE_SHA: d9f79527104694a223eb9d64309e9337f46909d6
    image: gameonwhales/sunshine
    ports: 
      - 47984-47990:47984-47990/tcp
      - 48010:48010
      - 47998-48000:47998-48000/udp
    runtime: ${DOCKER_RUNTIME}
    privileged: true
    volumes:
      # Xorg socket in order to get the screen
      - ${XORG_SOCKET}:/tmp/.X11-unix
      # Pulse socket, audio
      - ${PULSE_SOCKET_HOST}:${PULSE_SOCKET_GUEST}
      # Home directory: sunshine state + configs
      - ${local_state}/:/home/retro/
      # OPTIONAL: host dbus used by avahi in order to publish Sunshine for auto network discovery
      - ${DBUS}:/run/dbus:ro 
    ipc: ${SHARED_IPC}  # Needed for MIT-SHM, removing this should cause a performance hit see https://github.com/jessfraz/dockerfiles/issues/359
    environment:
      DISPLAY: ${XORG_DISPLAY}
      NVIDIA_DRIVER_CAPABILITIES: utility,video,graphics,display
      NVIDIA_VISIBLE_DEVICES: ${GPU_UUID}
      LOG_LEVEL: ${SUNSHINE_LOG_LEVEL}
      GOW_REQUIRED_DEVICES: /dev/uinput /dev/input/event* /dev/dri/*
      # Username and password for the web-ui at https://xxx.xxx.xxx.xxx:47990
      SUNSHINE_USER: ${SUNSHINE_USER}
      SUNSHINE_PASS: ${SUNSHINE_PASS}
      # Intel drivers, see https://wiki.debian.org/HardwareVideoAcceleration#Installation
      # LIBVA_DRIVERS_PATH: /usr/lib/x86_64-linux-gnu/dri/
      # LIBVA_DRIVER_NAME: i965 # or i965 for older generations
      XDG_RUNTIME_DIR: /tmp/.X11-unix
      PULSE_SERVER: ${PULSE_SERVER}


  #####################
  retroarch:
    depends_on:
      - sunshine
    runtime: ${DOCKER_RUNTIME}
    build:
      context: ./images/
      dockerfile: retroarch/Dockerfile
    image: gameonwhales/retroarch
    # network_mode: host
    privileged: true
    network_mode: ${UDEVD_NETWORK}
    volumes:
      # Followings are needed in order to get joystick support
      - /dev/input:/dev/input:ro
      - /run/udev/:/run/udev/:ro
      # Xorg socket in order to get the screen
      - ${XORG_SOCKET}:/tmp/.X11-unix
      # Pulse socket, audio
      - ${PULSE_SOCKET_HOST}:${PULSE_SOCKET_GUEST}
      # Home directory: retroarch games, downloads, cores etc
      - ${local_state}/:/home/retro/
      # some emulators need more than 64 MB of shared memory - see https://github.com/libretro/dolphin/issues/222
      # TODO: why shm_size doesn't work ??????
      - type: tmpfs
        target: /dev/shm
        tmpfs:
            size: ${SHM_SIZE}
    ipc: ${SHARED_IPC}  # Needed for MIT-SHM, removing this should cause a performance hit see https://github.com/jessfraz/dockerfiles/issues/359
    environment:
      DISPLAY: ${XORG_DISPLAY}
      NVIDIA_DRIVER_CAPABILITIES: utility,video,graphics,display
      NVIDIA_VISIBLE_DEVICES: ${GPU_UUID}
      # Which devices does GoW need to be able to use? The docker user will be
      # added to the groups that own these devices, to help with permissions
      # issues
      # These values are the defaults, but you can add others if needed
      GOW_REQUIRED_DEVICES: /dev/uinput /dev/input/event* /dev/dri/* /dev/snd/*
      PULSE_SERVER: ${PULSE_SERVER}

  ####################
  steam:
    depends_on:
      - sunshine
    runtime: ${DOCKER_RUNTIME}
    build:
      context: ./images/
      dockerfile: steam/Dockerfile
    image: gameonwhales/steam
    network_mode: ${UDEVD_NETWORK}
    privileged: true
    volumes:
      # Followings are needed in order to get joystick support
      - /dev/input:/dev/input:ro
      - /run/udev/:/run/udev:ro
      # Xorg socket in order to get the screen
      - ${XORG_SOCKET}:/tmp/.X11-unix
      # Pulse socket, audio
      - ${PULSE_SOCKET_HOST}:${PULSE_SOCKET_GUEST}
      # Home directory: client, games, downloads, etc
      - ${local_state}/:/home/retro/
      # The following is needed by the webview otherwise you'll get Less than 64MB of free space in temporary directory (https://github.com/microsoft/vscode/issues/111729#issuecomment-737399692)
      # TODO: why shm_size doesn't work ??????
      - type: tmpfs
        target: /dev/shm
        tmpfs:
            size: ${SHM_SIZE}
    ipc: ${SHARED_IPC}  # Needed for MIT-SHM, removing this should cause a performance hit see https://github.com/jessfraz/dockerfiles/issues/359
    environment:
      DISPLAY: ${XORG_DISPLAY}
      NVIDIA_DRIVER_CAPABILITIES: compat32,graphics,utility,display,video
      NVIDIA_VISIBLE_DEVICES: ${GPU_UUID}
      PROTON_LOG: 1
      LD_LIBRARY_PATH: /home/retro/.steam/ubuntu12_32/
      PULSE_SERVER: ${PULSE_SERVER}

```