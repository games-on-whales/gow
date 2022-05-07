---
layout: default
title: Unraid
parent: Headless
nav_order: 2
---

# Unraid
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

Unraid is missing the required `uinput` kernel module out of the box. We have
created [a plugin](https://github.com/games-on-whales/unraid-plugin) that adds that and we automated the builds using
Github Actions.

We are working to add more support so that you can run GOW easily via the plugin, for now, you'll have to manually run
the `docker-compose.yml`.

## Pre-requisites

> ⚠️ In order for Sunshine to stream your desktop you have to **have a monitor plugged** (or use a dummy plug).

While a dedicated GPU isn't strictly necessary (Sunshine does support SW encoding) it's highly recommended.

### Nvidia

If you have a Nvidia GPU you'll have to also install
the [nvidia-driver plugin](https://forums.unraid.net/topic/98978-plugin-nvidia-driver/)

### AMD

Users reported in the Discord channel that AMD works out of the box without having to install any additional driver.

## Installing GOW

Now that `uinput` is installed via the plugin, it's time to run GOW via Docker.  
Let's start by cloning the project locally:

> This will run on your current folder, if you want to keep the repo on the array storage you should first move to the
> desired folder with: `cd /mnt/user/<some/path/to/gow>`

```bash
git clone https://github.com/games-on-whales/gow.git
cd gow
mkdir local_state
```

Since GOW it's a composition of multiple docker containers we use [`docker-compose`](https://docs.docker.com/compose/)
in order to manage and spin them up, let's install it:

```bash 
curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 --output /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

If all went well you should be able to run: `docker-compose --version`.

Now it's time to download the containers prebuilt images:

```bash 
docker-compose pull
```

And start it!

> Nvidia users: before running it you should modify `DOCKER_RUNTIME=` to `DOCKER_RUNTIME=nvidia` option in the `.env`
> file

```bash 
docker-compose up -d # start the containers in background
```

This will take a some time to start, you can check the status using: `docker-compose ps` in case one or more containers
are stopped you can check the logs using: `docker-compose logs --follow`.

## Accessing GOW

If all the containers are up and running, connect over [Moonlight](https://moonlight-stream.org/) by manually adding the
IP address of the Unraid Host.   
To validate the PIN you can use the Sunshine web interface (at `https://<IP>:47990/` default username: `admin`,
password: `admin`)
or directly calling: `curl <IP>:47989/pin/<PIN>`.

From Moonlight open the `Desktop` app, from there you should be able to see your X11 apps running!

## Errors, issues?

- Checkout the [troubleshooting]({{ site.baseurl }}{% link _configuration/troubleshooting.md %}) page first
- [Open an issue on Github](https://github.com/games-on-whales/gow/issues/new)
- Reach out on the dedicated `#unraid` channel on [Discord](https://discord.gg/kRGUDHNHt2)