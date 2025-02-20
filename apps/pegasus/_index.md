# [Pegasus Front-end](https://pegasus-frontend.org) Image

"A cross platform, customizable graphical frontend for launching emulators and managing your game collection."

Demonstration of different themes: [youtube video](https://www.youtube.com/watch?v=WYAgfutLbVE)

[Themes Gallery](https://pegasus-frontend.org/tools/themes/)

## Building the image from scratch

```shell
SHA=latest
docker build -t gow/pegasus:${SHA} --no-cache --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:${SHA}" .
```
