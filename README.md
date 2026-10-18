# GOW - Games on Whales

[![Linux build and test](https://github.com/games-on-whales/gow/actions/workflows/auto-build.yml/badge.svg)](https://github.com/games-on-whales/gow/actions/workflows/auto-build.yml)
[![Discord](https://img.shields.io/discord/856434175455133727.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/kRGUDHNHt2)
[![GitHub license](https://img.shields.io/github/license/games-on-whales/wolf)](https://github.com/games-on-whales/wolf/blob/beta/LICENSE)
[![Donate button](https://img.shields.io/badge/Donate-Open%20Collective-blue.svg?color=blue)](https://opencollective.com/games-on-whales/donate)

A collection of Docker images ready to be used by [Wolf](https://github.com/games-on-whales/wolf) in order to run games
and apps on a remote host!

Read more about the included images and how to use them in [wildlife](https://games-on-whales.github.io/wildlife/)

## Image defaults and release channels

Fedora 44 is the primary GoW platform. The `beta`, `stable`, and `vYYYY.MM`
image tags select Fedora 44. Ubuntu is available as an explicit backup with
`beta-ubuntu`, `stable-ubuntu`, and `vYYYY.MM-ubuntu` tags. `stable` is published
only for the latest non-prerelease release; publishing an older release cannot
replace it. `fedora-44` remains available for existing integrations.

For local builds, use `bin/build-app.sh steam` (Fedora 44) or
`bin/build-app.sh steam ubuntu` (backup). See [.github/RELEASE_CHANNELS.md](.github/RELEASE_CHANNELS.md)
for the repository branch and release policy.
