# Troubleshooting

Here's a list of common problems, feel free to [open an issue](https://github.com/games-on-whales/gow/issues/new) if something is not listed here.
Make sure to read first the [overview](overview.md) and [components overview](overview.md) if some terms that is used here doesn't sound familiar to you.
 

## Error: Could not create Sunshine Mouse: No such file or directory

Make sure that `/dev/uinput/` is present in the host and that it does have the correct permissions:

```console
ls -la /dev/uinput
crw-rw---- 1 $USER input 10, 223 Jun  9 08:57 /dev/uinput # Check that $USER is not root but your current user
```

Try following this: https://github.com/chrippa/ds4drv/issues/93#issuecomment-265300511
(On Debian I had to modify `/etc/modules-load.d/modules.conf`, adding `/etc/modules-load.d/uinput.conf` didn't trigger anything to me)

Non permanent fix:
```console
sudo chmod 0660 /dev/uinput
```

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
```console
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
```console
docker exec -it gow_retroarch_1 id

uid=1000(retro) gid=1000(retro) groups=1000(retro),105(messagebus)
```

## How can I get the full logs of Xorg?

Xorg is logging more than what you can see from the command line, you have to get out the log file at `/var/log/Xorg.0.log` from inside the Docker container. Running the following should print out the full log file:
```
docker exec -it gow_xorg_1 cat /var/log/Xorg.0.log
```