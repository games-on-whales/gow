# Lutris Gamepad UI

![Lutris Gamepad UI screenshot](assets/screenshot.png)

An open-source. simple, TV-friendly, gamepad-navigable frontend for the Lutris game launcher on Linux. This application provides a "10-foot UI" designed for couch gaming, allowing you to browse and launch your Lutris library entirely with a gamepad.

### Check the original repository for more details
[lutris-gamepad-ui](https://github.com/andrew-ld/lutris-gamepad-ui)

# Easy Setup
Add the app profile in the .toml file:
```toml
    [[profiles.apps]]
    icon_png_path = 'https://raw.githubusercontent.com/HashimHS/gow/refs/heads/gamepadui/apps/gamepad-ui/assets/icon.png'
    start_virtual_compositor = true
    title = 'Gamepad UI'

        [profiles.apps.runner]
        base_create_json = '''{
  "HostConfig": {
    "IpcMode": "host",
    "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN", "SYS_ADMIN", "SYS_NICE"],
    "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
    "Ulimits": [{"Name":"nofile", "Hard":524288, "Soft":524288}],
    "Privileged": false,
    "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
  }
}
'''
        devices = []
        env = [ 'RUN_GAMESCOPE=1', 'GOW_REQUIRED_DEVICES=/dev/input/event* /dev/dri/* /dev/nvidia* /var/lutris/' ]
        image = 'docker.io/hashimhs/gamepadui:latest'
        mounts = ['lutris:/var/lutris:rw']
        name = 'WolfGamepad-UI'
        ports = []
        type = 'docker'
```
Restart Wolf.
