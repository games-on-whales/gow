# Pegasus Front-end

![Pegasus screenshot](assets/screenshot.png)

Pegasus is a powerful and flexible frontend for launching games, similar to EmulationStation. It provides a unified
interface for interacting with various emulators, eliminating the need to manage multiple emulator interfaces
separately.

## Getting Started

### ROM Directory Structure

By default, Pegasus is configured to look for ROMs in the `/ROMs` directory, with subdirectories for each platform. You
can either create the ROM directories in the format below or edit Pegasus to use your preferred location.

{{% details title="Full ROM Directory Structure" %}}

```
/ROMs/3do
/ROMs/amiga
/ROMs/amigacd32
/ROMs/arcade
/ROMs/atari2600
/ROMs/atari5200
/ROMs/atari7800
/ROMs/atarijaguar
/ROMs/atarijaguarcd
/ROMs/atarilynx
/ROMs/atarist
/ROMs/gb
/ROMs/gba
/ROMs/gbc
/ROMs/gc
/ROMs/genesis
/ROMs/megacd
/ROMs/model2
/ROMs/model3
/ROMs/n64
/ROMs/naomi
/ROMs/neogeo
/ROMs/nes
/ROMs/ngp
/ROMs/ngpc
/ROMs/ps2
/ROMs/ps3
/ROMs/psp
/ROMs/psx
/ROMs/saturn
/ROMs/sega32x
/ROMs/segacd
/ROMs/snes
/ROMs/snes_widescreen
/ROMs/switch
/ROMs/virtualboy
/ROMs/wii
/ROMs/wiiu
/ROMs/wonderswan
/ROMs/wonderswancolor
/ROMs/xbox
```

{{% /details %}}

### Setting Up ROM Directories

To make your roms accessible to Pegasus within the container, you need to create a bind mount that maps your host ROM
folder to the `/ROMs` directory in the container.
This is done by editing the `config.toml` file; ex:

```toml 
mounts = [
    "/mnt/PATH_TO_ROMS_IN_YOUR_HOST/:/ROMs/:rw" # <-- EDIT HERE
]
```

## Customization

### Theming

Pegasus supports extensive customization through themes. You can change the look and feel of your frontend to suit your
preferences.

- For a demonstration of different themes, watch this https://www.youtube.com/watch?v=WYAgfutLbVE[YouTube video].
- Browse and download themes from the official https://pegasus-frontend.org/tools/themes/[Pegasus Themes Gallery].

To install a theme, you need to launch the Pegasus app at least once, then download the theme and place in:

`<hostapps_folder>/Pegasus/.config/pegasus-frontend/themes`

On the next Pegasus launch, you will be able to select the theme from within the settings.

## Troubleshooting and Additional Resources

If you encounter any issues or need more information, consider the following resources:

- Official Pegasus Documentation: https://pegasus-frontend.org/docs/
- Pegasus FAQ: https://pegasus-frontend.org/docs/faq/
- Community Forums: https://pegasus-frontend.org/community/

For specific issues related to this container or its configuration, please refer to the project's issue tracker or
community support channels.