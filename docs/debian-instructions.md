# Debian/Ubuntu instructions

Make sure to checkout the [Overview](overview.md) first.

## Quickstart

```console
git clone https://github.com/games-on-whales/gow.git
cd gow
docker-compose pull
docker-compose up
```

Connect over Moonlight by manually adding the IP address of the PC running the Docker container. To validate the PIN you can use the Sunshine web interface (at `https://<IP>:47990/` username: sunshine, password is auto generated on startup check the docker logs.) or directly calling: `curl <IP>:47989/pin/<PIN>`.

From Moonlight open the `Desktop` app, from there you should be able to see your X11 apps running!

## Next steps

 - Checkout how to [configure RetroArch](retroarch-first-start.md)
 - Head [back to the Documentation](README.md) to configure and use your GPU (if you have one)
