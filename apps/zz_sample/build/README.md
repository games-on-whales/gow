# Sample GUI Application Container

This Dockerfile provides a base template for creating containerized GUI applications with proper system integration.

## Features

- Sandboxed execution using bubblewrap
- D-Bus and NetworkManager support
- Basic X11/GUI utilities
- Font rendering support
- Proper system integration with host

## Prerequisites

- Docker
- A base image that supports GUI applications (specified via BASE_APP_IMAGE)

## Usage

1. Build the image:
```bash
docker build --build-arg BASE_APP_IMAGE=your-base-image:tag -t your-app-name .
```

2. Required Volume Mounts:
- `/tmp/.X11-unix`: X11 socket for GUI
- `/dev/dri`: GPU access (if needed)
- Additional mounts as needed by your application

3. Required Environment Variables:
- `DISPLAY`: For X11 forwarding
- `XDG_RUNTIME_DIR`: Set to `/tmp/.X11-unix`

## Customization

1. Additional Packages:
   - Add your application-specific packages to the REQUIRED_PACKAGES argument
   - Add any packages to avoid in AVOID_PACKAGES

2. Startup Scripts:
   - `/opt/gow/startup-app.sh`: Main application startup script
   - `/etc/cont-init.d/system-services.sh`: System services initialization

## Known Issues and Solutions

1. Bubblewrap and Capabilities:
   - The custom bubblewrap build addresses CAP_SYS_ADMIN requirements
   - See ignore_capabilities.patch for details

2. NetworkManager:
   - A blank config file is created to ensure proper device detection
   - Location: `/etc/NetworkManager/conf.d/10-globally-managed-devices.conf`

## Security Considerations

- Container runs without privileged mode
- Bubblewrap provides additional sandboxing
- NVIDIA driver conflicts are avoided through AVOID_PACKAGES

## Package Reference

### Core System Packages
The following packages are included by default to provide essential GUI and system functionality:

#### D-Bus and System Communication
- `dbus-daemon`: D-Bus message bus daemon
- `dbus-system-bus-common`: D-Bus system bus support
- `dbus-session-bus-common`: D-Bus session bus support
- `network-manager`: Network connectivity management
- `ibus`: Input method framework

#### System Utilities
- `curl`: Transfer data from or to a server
- `pkexec`: PolicyKit execution helper
- `xz-utils`: XZ-format compression utilities
- `file`: File type determination
- `pciutils`: PCI utilities
- `lsb-release`: Linux Standard Base information

#### GUI and Desktop Integration
- `zenity`: Display GTK+ dialogs
- `xdg-user-dirs`: Tool to manage user directories
- `xdg-utils`: Desktop integration utilities
- `mesa-utils`: OpenGL utilities

#### Font Support
- `libfontconfig1`: Font configuration and customization library
- `libfreetype6`: FreeType font rendering engine

### Avoided Packages
The following packages are explicitly avoided to prevent conflicts with host system:
- `nvidia-driver-libs-`: Prevents NVIDIA driver conflicts
- `nvidia-vulkan-icd-`: Prevents Vulkan ICD conflicts

### Adding Additional Packages
To add more packages for your specific application:
1. Modify the `REQUIRED_PACKAGES` argument in the Dockerfile
2. Ensure any added packages are available in the repositories:
   - Packages must exist in the default Ubuntu apt repositories
   - For packages from additional sources, add the repository to the `CUSTOM_REPOSITORIES` section of the Dockerfile
3. Ensure any added packages don't conflict with host system integration
4. Consider documenting any additional packages in your application's README

See the `CUSTOM_REPOSITORIES` section in the Dockerfile for examples of adding repositories for specialized packages.