---
layout: default
title: Unraid
parent: Headless
nav_order: 2
---

# Unraid

Unraid is missing the required `uinput` kernel module out of the box. We have created [a plugin](https://github.com/games-on-whales/unraid-plugin) that adds that and we automated the builds using Github Actions.

We are working to add more support so that you can run GOW easily via the plugin, for now, you'll have to manually run the `docker-compose.yml`.
