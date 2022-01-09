---
layout: default
title: Steam 
nav_order: 1
---

# Steam
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

You can use the `gameonwhales/steam` image to play Steam games on GOW. It's highly recommended using a GPU in order to run Steam games.

There are a few connected bits that we took care for you, here's a rundown of the possible errors you might encounter:

## Can I run Windows games?

Surprisingly, you can! And it's fairly easy to do it using [proton](https://www.protondb.com/) which is integrated in Steam via [Steam Play](https://steamcommunity.com/games/221410/announcements/detail/1696055855739350561).

In order to enable it:
- Steam > Settings
- Steam Play
- [✓] Enable Steam Play for supported titles
- (optional) [✓] Enable Steam Play for all other titles

## Something is wrong, where are the logs?

There are a lot of different places for logs, for example, each game logs in a different folder but here are a few hints on where things are:
 - `local_state/.steam/debian-installation/error.log`
   - This is where most of the issues with the Steam client are logged
 -  `local_state/.config/`
   - This is where games *usually* put log and config files
   - For example `local_state/.config/unity3d/NoBrakesGames/Human/Player.log` is the log file for Human Fall Flat
 - `local_state/Steam/logs/bootstrap_log.txt`
   -  This is the log file related to starting/updating the steam client

## UI: I can't see my games or store (black pages) 

Steam includes an integrated webview, there are a few things to check if you hit this issue:
  - Make sure that `/dev/shm` is *big enough*
    - `docker exec -it gow_steam_1 df -h`
    - if /dev/shm is 64MB double check your docker-compose file
  - Checkout the logs at `local_state/.steam/debian-installation/error.log` for more info on the specific issue.
