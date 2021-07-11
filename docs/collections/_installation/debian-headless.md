---
layout: default
title: Debian/Ubuntu
parent: Headless
nav_order: 1
---
# Debian/Ubuntu instructions

Make sure to checkout the [Overview]({{ site.baseurl }}{% link _overview/overview.md %}) first.

## Requirement: uinput

This is a required kernel module in order for Sunshine to manage and create virtual devices (mouse,joypad, etc etc.).

Make sure that `/dev/uinput/` is present in the host.

```
ls -la /dev/uinput
crw------- 1 root root 10, 223 Jul 15 11:46 /dev/uinput
```

## Quickstart

```
git clone https://github.com/games-on-whales/gow.git
cd gow
mkdir local_state
sudo docker-compose pull
sudo docker-compose up
```

Connect over Moonlight by manually adding the IP address of the PC running the Docker container. To validate the PIN you can use the Sunshine web interface (at `https://<IP>:47990/` username: sunshine, password is auto generated on startup check the docker logs.) or directly calling: `curl <IP>:47989/pin/<PIN>`.

From Moonlight open the `Desktop` app, from there you should be able to see your X11 apps running!

## Next steps

 - Checkout the [troubleshooting]({{ site.baseurl }}{% link _configuration/troubleshooting.md %}) page if anything is not working on your side
 - Check out how to configure and use your GPU in order to get HW acceleration (if you have one)
