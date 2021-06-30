# How can I use GOW?

You should be able to run any Graphical Application on top of the basic combination of `Xorg` + `PulseAudio` + `Sunshine`, for example if you replace `RetroArch` with the following in the `docker-compose.yml` file you should be able to navigate the web using Firefox! 

```yaml
firefox:
depends_on: 
    - xorg
    - pulse
    - sunshine
image: andrewmackrodt/firefox-x11
volumes:       
    - xorg:/tmp/.X11-unix
    # This image needs these folders, 
    # we can easily pass a local folder instead.
    # just make sure to chomd -R ${id}:${id} ./local_state
    - ${local_state}/ffox:/run/user/1000
    - ${local_state}/.config/pulse:/home/ubuntu/.config/pulse:ro
environment: 
    DISPLAY: ":0"
    LOG_LEVEL: info
    PULSE_SERVER: pulse # The name of the pulse container is the hostname in the virtual network
```

A few things to notice:
 - This is an image that we didn't built [`andrewmackrodt/firefox-x11`](https://github.com/andrewmackrodt/dockerfiles/tree/master/firefox-x11) but it's open source and it's a great example of running a container which wasn't built with GOW in mind.

 - This container doesn't need to be run with ` privileged: true` nor `network_mode: host` this is because mouse and keyboard events are handled by `Xorg` and passing the `X11` socket is enough to have display and inputs
    - This increase security for non trusted containers by restricting the things they can access
    - If you would like to also have joypad support you'll have to use `privileged` and `host` network just like in the `RetroArch` example

The main advantage is that if you have a desktop environment already you can run this Firefox container even without using any of the GOW parts because you already have `Xorg`, `PulseAudio` and possibly a keyboard and mouse connected.

If you don't have a desktop environment or you would like to have a remote desktop solution that **it's faster** then VNC or RDP that let's you run GUI **with HW acceleration** than **GOW** is the solution for you! 

And it lets you re-use docker containers that can be run in both environments! [Heres a blog post](https://blog.jessfraz.com/post/docker-containers-on-the-desktop/#guis) with a few GUI docker containers like:
- Chrome
- Spotify
- Gparted
- Skype

:rocket: The sky is the limit! :rocket: