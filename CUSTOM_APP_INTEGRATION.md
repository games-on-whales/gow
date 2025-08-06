# Custom App Integration Example

To add your own Docker container to Wolf, create a new directory structure:

```
apps/
└── your-custom-app/
    ├── _index.md                    ← Documentation
    ├── assets/
    │   ├── icon.png                 ← App icon
    │   ├── screenshot.png           ← Screenshot
    │   └── wolf.config.toml         ← Wolf configuration
    └── build/                       ← Optional: Custom Dockerfile
        └── Dockerfile
```

## Wolf Configuration Template

Here's a template for `wolf.config.toml`:

```toml
[[apps]]
title = 'Your App Name'
icon_png_path = "path/to/icon.png"

[apps.runner]
type = 'docker'
name = 'WolfYourApp'
image = 'your-docker-image:tag'
env = [
    'DISPLAY=:99',
    'GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*'
]
devices = []
mounts = [
    '/host/path:/container/path:rw'
]
ports = []
base_create_json = """
{
  "HostConfig": {
    "IpcMode": "host",
    "Privileged": false,
    "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN"],
    "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
  }
}
"""
```

## Key Configuration Options:

- **image**: Your Docker image (can be from DockerHub, GHCR, etc.)
- **mounts**: Persistent storage (save games, settings)
- **env**: Environment variables
- **base_create_json**: Docker container settings
- **Privileged**: Set to true for root access (like your XFCE)
