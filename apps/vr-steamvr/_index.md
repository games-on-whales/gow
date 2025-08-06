# VR Streaming (ALVR + SteamVR)

![VR Streaming](assets/screenshot.png)

Stream VR games from your server to Quest 3 headsets wirelessly using ALVR and SteamVR.

## What is ALVR?

ALVR (Air Light VR) is an open-source solution that allows you to stream PC VR games to standalone VR headsets like Quest 3 over WiFi. It provides:

- **Low-latency streaming** optimized for VR
- **Wireless freedom** - no cables required
- **High-quality video** with adaptive bitrate
- **Full controller support** including haptic feedback
- **6DOF tracking** for both headset and controllers

## Features

- ✅ **Quest 3 Support**: Officially supports Meta Quest 3 and Quest 3S
- ✅ **SteamVR Integration**: Full compatibility with SteamVR games
- ✅ **120Hz/90Hz Support**: High refresh rate for smooth gameplay
- ✅ **Adaptive Quality**: Automatically adjusts quality based on network conditions
- ✅ **Web Interface**: Easy configuration via web browser
- ✅ **Root Access**: Full system control for advanced VR setups

## Setup Instructions

### 1. Network Requirements
- **5GHz WiFi** connection for best performance
- Both your server and Quest 3 must be on the **same network**
- Wired ethernet connection for your server is recommended

### 2. Quest 3 Setup
1. Enable **Developer Mode** on your Quest 3
2. Install **ALVR Client** from SideQuest or directly via APK
3. Connect Quest 3 to the same WiFi network as your server

### 3. Server Configuration
1. Start the VR Streaming app from Wolf/Moonlight
2. Open web browser and go to `http://YOUR_SERVER_IP:8082`
3. Configure video quality, audio settings, and tracking options
4. Your Quest 3 should appear in the client list - click "Trust" to connect

### 4. SteamVR Setup
1. Install SteamVR from Steam store (will be auto-installed)
2. Launch any VR game from Steam
3. The game will stream directly to your Quest 3

## Usage

### Starting VR Session
1. **Connect via Moonlight** to the "VR Streaming" app
2. **Put on Quest 3** and launch ALVR client app
3. **Wait for connection** - you'll see the SteamVR environment
4. **Launch VR games** from Steam Big Picture or SteamVR interface

### Web Interface
Access `http://YOUR_SERVER_IP:8082` to configure:
- **Video Quality**: Bitrate, resolution, refresh rate
- **Audio Settings**: Microphone and game audio
- **Tracking**: Controller offsets and calibration
- **Network**: Connection protocol and ports

## Performance Optimization

### Network
- Use **5GHz WiFi** (not 2.4GHz)
- Ensure strong WiFi signal (close to router)
- Consider WiFi 6/6E router for best performance
- Use **wired ethernet** for your server

### Video Quality
- Start with **100 Mbps** bitrate, adjust as needed
- Use **90Hz** refresh rate for Quest 3
- Enable **adaptive bitrate** for automatic quality adjustment
- **2880x1700** resolution recommended for Quest 3

### System
- Ensure GPU drivers are up to date
- Close unnecessary applications
- Use **dedicated GPU** (not integrated graphics)
- Enable **GPU scheduling** in Windows (if applicable)

## Troubleshooting

### Connection Issues
- Verify both devices are on same network
- Check firewall settings (ports 8082, 9943, 9944)
- Restart ALVR server if connection fails
- Try different stream protocol (TCP vs UDP)

### Performance Issues
- Lower bitrate if experiencing lag
- Reduce resolution if frames are dropping
- Check network bandwidth usage
- Ensure Quest 3 has good WiFi signal

### Audio Issues
- Check audio device selection in ALVR settings
- Verify microphone permissions in Quest 3
- Try different audio bitrate settings

## Advanced Configuration

### Custom Scripts
- `/usr/local/bin/start-alvr` - Start ALVR server manually
- `/usr/local/bin/start-steamvr` - Launch SteamVR directly

### Environment Variables
- `ALVR_SERVER_HOST=0.0.0.0` - Server bind address
- `ALVR_WEB_PORT=8082` - Web interface port
- `STEAM_VR=1` - Enable VR mode in Steam

### File Locations
- ALVR Config: `/home/retro/.local/share/alvr/`
- Steam VR: `/home/retro/.steam/steam/steamapps/common/SteamVR/`
- OpenXR Runtime: `/home/retro/.config/openxr/1/active_runtime.json`

## Supported VR Games

Most SteamVR games work out of the box, including:
- **Half-Life: Alyx**
- **Beat Saber** (PC version)
- **VRChat**
- **Pavlov VR**
- **The Lab**
- **Boneworks/Bonelab**
- And thousands more!

## Requirements

- **Quest 3/3S headset** with ALVR client installed
- **5GHz WiFi network** with good signal strength
- **Gaming PC/Server** with dedicated GPU (GTX 1060 or better)
- **Steam account** with SteamVR installed

## Security Notes

This container runs with root privileges to provide:
- Direct GPU access for VR rendering
- Network configuration for streaming
- System-level VR driver installation
- Hardware device access for tracking
