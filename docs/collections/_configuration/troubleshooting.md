---
layout: default
title: Troubleshooting
nav_order: 2
---

# Troubleshooting
{: .no_toc }

Here's a list of common problems, feel free to [open an issue](https://github.com/games-on-whales/gow/issues/new) if something is not listed here.
Make sure to read first the [overview](/overview/overview/) and the [components overview](/overview/components-overview/) pages of the docs.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>



## mkdir: cannot create directory '/home/retro/sunshine/': Permission denied

This means that your `local_state` folder as defined in the [`.env`](../.env) file is not owned by user 1000. You can fix this by 

```
sudo chown -R 1000:1000 local_state
```

## Error: Could not create Sunshine Mouse: No such file or directory

Make sure that `/dev/uinput/` is present in the host and that it does have the correct permissions:

```
ls -la /dev/uinput
crw-rw---- 1 $USER input 10, 223 Jun  9 08:57 /dev/uinput # Check that $USER is not root but your current user
```

If that's not the case try following:
 - The official Sunshine instructions about `udev` at: https://github.com/loki-47-6F-64/sunshine#setup
 - The solution proposed at: https://github.com/chrippa/ds4drv/issues/93#issuecomment-265300511
    - (On Debian I had to modify `/etc/modules-load.d/modules.conf`, adding `/etc/modules-load.d/uinput.conf` didn't trigger anything to me)

Or if you are in a rush you can run the following:

```
sudo chmod 0660 /dev/uinput
sudo chown 1000:input /dev/uinput
```

but remember that on startup you'll have to do it again.


## I can use my mouse and keyboard but my joypad doesn't work

If keyboard and mouse are working it means that `uinput`, `Xorg` and `Sunshine` are correctly working. 

Joypad devices are created by `Sunshine` on connection, only if the client have one attached. Joypads are not handled by `Xorg` but they are directly accessed by X11 app, that's why on `RetroArch` we have to use:

```yaml
network_mode: host
privileged: true
volumes: 
    - /dev/input:/dev/input:ro
    - /run/udev:/run/udev:ro
    - /dev/uinput:/dev/uinput:ro
```

If this is already present in your `docker-compose.yml` you have to check for file permissions. Make sure that `messagebus` gid inside the containers maps to `input` gid on your host, in order to do that first check what's the gid of the files inside `/dev/input` as seen by the docker container:
```
docker exec -it gow_retroarch_1 ls -la /dev/input

drwxr-xr-x  4 root root          380 Jun 30 17:25 .
drwxr-xr-x 13 root root         2940 Jun 30 17:25 ..
drwxr-xr-x  2 root root           80 Jun 27 09:43 by-id
drwxr-xr-x  2 root root          160 Jun 27 09:43 by-path
crw-rw----  1 root messagebus 13, 64 Jun 27 09:43 event0
crw-rw----  1 root messagebus 13, 65 Jun 27 09:43 event1
crw-rw----  1 root messagebus 13, 66 Jun 27 09:43 event2
crw-rw----  1 root messagebus 13, 67 Jun 27 09:43 event3
crw-rw----  1 root messagebus 13, 68 Jun 27 09:43 event4
...
...
```

Then check that the current user inside the container is part of the `messagebus` group:
```
docker exec -it gow_retroarch_1 id

uid=1000(retro) gid=1000(retro) groups=1000(retro),105(messagebus)
```

## RetroArch is missing icons!

> Using the keyboard you can move using the arrows and get back to the previous menu by pressing backspace

From the **Main Menu** > **Online Updater** select:
- Update Core Info Files
- Update assets

Press `F` to toggle fullscreen if you need to.

## How can I get the full logs of Xorg?

Xorg is logging more than what you can see from the command line, you have to get out the log file at `/var/log/Xorg.0.log` from inside the Docker container. Running the following should print out the full log file:
```
docker exec -it gow_xorg_1 cat /var/log/Xorg.0.log
```
