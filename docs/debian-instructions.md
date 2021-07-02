# Debian/Ubuntu instructions

Make sure to checkout the [Overview](overview.md) first.

## Requirement: uinput setup

This is a required kernel module in order for Sunshine to manage and create virtual devices (mouse,joypad, etc etc.).

Make sure that `/dev/uinput/` is present in the host and that it does have the correct permissions:

```console
ls -la /dev/uinput
crw-rw---- 1 $USER input 10, 223 Jun  9 08:57 /dev/uinput # Check that $USER is not root but your current user
```

If that's not the case try following:
 - The official Sunshine instructions about `udev` at: https://github.com/loki-47-6F-64/sunshine#setup
 - The solution proposed at: https://github.com/chrippa/ds4drv/issues/93#issuecomment-265300511
    - (On Debian I had to modify `/etc/modules-load.d/modules.conf`, adding `/etc/modules-load.d/uinput.conf` didn't trigger anything to me)

Or if you are in a rush you can run the following:

```console
sudo chmod 0660 /dev/uinput
sudo chown 1000:input /dev/uinput
```

but remember that on startup you'll have to do it again.

## Quickstart

```console
git clone https://github.com/games-on-whales/gow.git
cd gow
mkdir local_state
sudo docker-compose pull
sudo docker-compose up
```

Connect over Moonlight by manually adding the IP address of the PC running the Docker container. To validate the PIN you can use the Sunshine web interface (at `https://<IP>:47990/` username: sunshine, password is auto generated on startup check the docker logs.) or directly calling: `curl <IP>:47989/pin/<PIN>`.

From Moonlight open the `Desktop` app, from there you should be able to see your X11 apps running!

## Next steps

 - Checkout the [troubleshooting](troubleshooting.md) page if anything is not working on your side
 - Head [back to the Documentation](README.md) to configure and use your GPU in order to get HW acceleration (if you have one)
