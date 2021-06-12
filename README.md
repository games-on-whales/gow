# abeltramo/retroarch-remote

Running [RetroArch](https://www.retroarch.com/) on Docker with [Sunshine](https://github.com/loki-47-6F-64/sunshine) so that you can connecting to it using [Moonlight](https://moonlight-stream.org/) on any supported client.


## How to use

On the host check that PulseAudio is up and running for the root user
```console
sudo pacat -vvvv /dev/urandom

Opening a playback stream with sample specification 's16le 2ch 44100Hz' and channel map 'front-left,front-right'.
Connection established.
Stream successfully created.
Buffer metrics: maxlength=4194304, tlength=352800, prebuf=349276, minreq=3528
Using sample spec 's16le 2ch 44100Hz', channel map 'front-left,front-right'.
Connected to device alsa_output.pci-0000_02_0c.0.analog-stereo (index: 0, suspended: no).
Stream started.
...
```

If it's not running you can start it for root (NON PERMANENT SOLUTION)
```console
sudo pulseaudio -D
```

Make sure that /dev/uinput have the correct permissions.
Try following this: https://github.com/chrippa/ds4drv/issues/93#issuecomment-265300511
(On Debian I had to modify `/etc/modules-load.d/modules.conf`, adding `/etc/modules-load.d/uinput.conf` didn't trigger anything to me)
```console
ls -la /dev/uinput
crw-rw---- 1 $USER input 10, 223 Jun  9 08:57 /dev/uinput # Check that $USER is not root but your current user
```
Non permanent fix:
```console
sudo chmod 0660 /dev/uinput
```

Build the docker image

```console
sudo docker build -t abeltramo/retroarch .
```

Start it

```console
sudo docker run --privileged -it --rm --name retroarch --net=host \
    --volume /run/user/$(id -u)/pulse:/run/user/1000/pulse \
    --env RESOLUTION=1920x1080x24 \
    --env LOG_LEVEL=DEBUG \
    abeltramo/retroarch
```

Visit https://localhost:47990/ for the web config view
Validate pin on Moonlight Connection (on server)
```console
curl localhost:47989/pin/XXXX
```