# Battle.net

![Battle.net screenshot](assets/screenshot.png)

Blizzard's game launcher for World of Warcraft, Diablo, Overwatch, Call of Duty, and more.

## How it works

Battle.net runs through [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher) with GE-Proton in the Steam Linux Runtime (the same stack the Lutris image uses), so games get Proton's DXVK and vkd3d-proton (DX11 and DX12).

Everything is baked into the image at build time, so nothing is downloaded when the app starts: GE-Proton (pinned), the Steam Linux Runtime, a Proton-created prefix and a complete Battle.net installation. On first launch the prefix is copied to the persistent mount, so logins and installed games survive restarts. The image is run by any uid:gid Wolf is configured with (`run_uid`/`run_gid` of the paired client); the persistent mount must be writable for that uid.

## Configuration

pressure-vessel (the Steam Linux Runtime sandbox) needs more than the default Wolf runner settings: no seccomp/AppArmor confinement, a few capabilities and the host IPC namespace. With the host IPC namespace `/dev/shm` is a large tmpfs, which the image uses for pressure-vessel's per-launch runtime copy; it is what makes start-up take seconds instead of minutes.

```toml
[[profiles.apps]]
title = "Battle.net"
start_virtual_compositor = true

    [profiles.apps.runner]
    type = "docker"
    name = "WolfBattlenet"
    image = "ghcr.io/games-on-whales/battlenet:edge"
    mounts = ["/path/to/battlenet-persist:/home/retro-persist:rw"]
    env = [
        "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*",
        "XDG_RUNTIME_DIR=/tmp/runtime-retro",
        "RUN_SWAY=true"
    ]
    base_create_json = """
    {
      "HostConfig": {
        "IpcMode": "host",
        "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
        "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
        "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
      }
    }
    """
```

## Notes

- First launch copies the prefix to the persistent mount (a few seconds on SSD/ZFS). It is owned by the uid Wolf runs the container with.
- The Battle.net launcher UI is GPU-rendered (`HardwareAcceleration=true`, set in the baked `Battle.net.config`); games use the GPU through Proton.
- `/dev/shm` needs about 1.5 GB free for the runtime copy; with less (e.g. without `IpcMode: host`, Docker's default is 64 MB) the image falls back to a slow directory in the persistent mount.
- Optional shared game library: mount a host directory at `/games` (e.g. `/path/to/games:/games:rw`) and it appears as drive `D:` in the prefix, also inside the Steam Linux Runtime sandbox. Install games to `D:\` in Battle.net. Several users can mount the same directory, but only one should run or update the games at a time.
- The session ends on its own once the Battle.net client has been closed for 30 s and no game is left running (a helper a game leaves behind would otherwise keep the container open). Disable with `BNET_AUTO_EXIT=0`, change the wait with `BNET_EXIT_GRACE` (seconds) or the helper processes to ignore with `BNET_EXIT_IGNORE` (regex) in `bnet.env`; blockers are logged to `auto-exit.log` in the persistent mount.
- Extra environment can be set in `bnet.env` in the persistent mount (sourced by the start script before launching).
- Tested on AMD (Mesa/radv). The image is installed with the `enUS` language; the in-app region and language can be changed after logging in.
