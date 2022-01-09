---
layout: default
title: Kubernetes
parent: Headless
nav_order: 4
---
# Kubernetes instructions

Make sure to checkout the [Overview]({{ site.baseurl }}{% link _overview/overview.md %}) first.

## Requirement

### Kubernetes

At least version 1.18 is required.

If you are considering a cluster for multiple home applications then [this template](https://github.com/k8s-at-home/template-cluster-k3s) might be a good start.

### uinput

This is a required kernel module in order for Sunshine to manage and create virtual devices (mouse, joypad, etc.).

Make sure that `/dev/uinput/` is present in the Kubernetes nodes where you intend to run.

```
ls -la /dev/uinput
crw------- 1 root root 10, 223 Jul 15 11:46 /dev/uinput
```

### Graphic card

You need to have a graphic card supporting HW acceleration in Xorg.

If you run your Kubernetes workers into a Virtual Machine ensure you pass it a graphic card. You can use PCI passthrough for this.

## Quickstart

```
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update
helm install games-on-whales k8s-at-home/games-on-whales
```

Connect over Moonlight by manually adding the IP address of the worker node running the Helm chart pod. To validate the PIN you can use the Sunshine web interface (at `https://<IP>:47990/` username: `admin`, password is `admin` (at least you changed them in your Helm instance values) or directly calling: `curl <IP>:47989/pin/<PIN>`.

From Moonlight open the `Desktop` app, from there you should be able to see your X11 apps running!

## Next steps

 - Adjust your Helm chart settings - see the [instructions](https://github.com/k8s-at-home/charts/tree/master/charts/stable/games-on-whales)
 - Checkout the [troubleshooting]({{ site.baseurl }}{% link _configuration/troubleshooting.md %}) page if anything is not working on your side
 - Check out how to configure and use your GPU in order to get HW acceleration (if you have one)
