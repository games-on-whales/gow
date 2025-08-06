# Desktop (XFCE)

![XFCE Desktop screenshot](assets/screenshot.png)

A lightweight desktop environment for Unix-like operating systems.
It aims to be fast and low on system resources while being visually appealing and user-friendly.

## Installing applications

In this configuration, XFCE is set up to use **Flatpak in user mode** by default.  
Flatpak is a software utility for software
deployment, package management, and application virtualization for Linux. By using Flatpak in user mode, users can
install and manage applications from the Flatpak store without needing administrative privileges or modifying the base
Docker image.  
This setup enhances flexibility and security, as users can add or remove applications independently of the
underlying system.

## Root Access

For advanced system administration tasks, this XFCE configuration provides several ways to gain root privileges:

1. **Full sudo access**: The `retro` user has passwordless sudo access to all commands
2. **Root shell script**: Run `root-shell` from any terminal to switch to a root shell
3. **Container runs privileged**: The Docker container runs with elevated privileges and full system access

**Security Note**: The container runs with `Privileged: true` and extensive capabilities, providing near-complete system access within the containerized environment.
