# VR Streaming Setup Guide for Quest 3

This guide will help you set up wireless VR streaming from your Linux server to Quest 3 headsets using ALVR and SteamVR.

## Quick Overview

**What you're building:**
```
Quest 3 Headset ←→ WiFi ←→ Linux Server (Docker + ALVR + SteamVR) ←→ Wolf ←→ Moonlight Client
```

## Prerequisites

### Hardware Requirements
- **Quest 3/3S headset**
- **Gaming server** with dedicated GPU (GTX 1060+ or RX 580+)
- **5GHz WiFi router** (WiFi 6 recommended)
- **Wired ethernet** connection for server (recommended)

### Software Requirements
- **Wolf server** running on your Linux host
- **Developer mode** enabled on Quest 3
- **ALVR client** installed on Quest 3

## Step 1: Prepare Your Quest 3

### Enable Developer Mode
1. Download **Meta Quest Mobile App** on your phone
2. Log in with your Meta account
3. Go to **Settings** → **Developer Mode**
4. Create a developer organization (if needed)
5. Enable **Developer Mode** on your Quest 3

### Install ALVR Client
**Option A: Via SideQuest (Recommended)**
1. Install **SideQuest** on your PC
2. Connect Quest 3 via USB cable
3. Search for "ALVR" in SideQuest
4. Install ALVR client to your Quest 3

**Option B: Direct APK Install**
1. Download ALVR APK from [GitHub releases](https://github.com/alvr-org/ALVR/releases)
2. Use `adb install` to install the APK

## Step 2: Build VR Container

```bash
# Navigate to your GOW directory
cd /path/to/gow

# Make build script executable
chmod +x bin/build-vr.sh

# Build the VR container
./bin/build-vr.sh
```

## Step 3: Configure Wolf Server

Your VR app is now available in Wolf! The configuration includes:

- **ALVR Server**: Handles VR streaming to Quest 3
- **SteamVR**: Provides VR runtime for Steam games
- **Web Interface**: Available on port 8082
- **Root Access**: Full system privileges for VR drivers

## Step 4: Network Setup

### Router Configuration
1. **Use 5GHz WiFi** (not 2.4GHz)
2. **Place Quest 3 close** to router for best signal
3. **Connect server via ethernet** if possible
4. **Open firewall ports** if needed:
   - TCP 8082 (ALVR web interface)
   - UDP 9943, 9944 (ALVR streaming)

### Test Network
```bash
# Check network speed from Quest 3
# Use a WiFi analyzer app to verify 5GHz connection
# Ensure both devices can ping each other
```

## Step 5: First VR Session

### Start the VR Server
1. **Connect via Moonlight** to your Wolf server
2. **Select "VR Streaming"** from the app list
3. **Wait for startup** - this may take a minute

### Configure ALVR
1. **Open web browser** on any device
2. **Navigate to** `http://YOUR_SERVER_IP:8082`
3. **Configure settings**:
   - Video: 100 Mbps bitrate, 90Hz refresh rate
   - Audio: Enable microphone and game audio
   - Tracking: Default Quest 3 settings

### Connect Quest 3
1. **Put on Quest 3 headset**
2. **Launch ALVR app** from your library
3. **Wait for server discovery** - your server should appear
4. **Click "Trust"** when prompted
5. **You should see SteamVR environment!**

## Step 6: Install and Play VR Games

### Via SteamVR Store
1. **Open Steam** (should start automatically)
2. **Go to VR section** in Steam store
3. **Purchase/install VR games**
4. **Launch from SteamVR interface**

### Popular VR Games to Try
- **The Lab** (Free) - Great for testing
- **Half-Life: Alyx** - AAA VR experience
- **Beat Saber** - Rhythm game
- **VRChat** - Social VR
- **Pavlov VR** - VR FPS

## Performance Optimization

### ALVR Settings (Web Interface)
```json
{
  "video": {
    "bitrate": 100000000,  // 100 Mbps - adjust based on network
    "resolution": "2880x1700",  // Quest 3 native resolution
    "fps": 90,  // Quest 3 refresh rate
    "codec": "H264"  // Best compatibility
  },
  "audio": {
    "bitrate": 128000,  // 128 kbps
    "sample_rate": 48000
  }
}
```

### System Optimization
```bash
# Check GPU utilization
nvidia-smi  # For NVIDIA
radeontop   # For AMD

# Monitor network usage
iftop

# Check VR performance in SteamVR settings
# Enable performance graphs in SteamVR
```

## Troubleshooting

### Connection Issues
```bash
# Check if ALVR server is running
docker ps | grep vr-steamvr

# Check network connectivity
ping QUEST_3_IP
ping SERVER_IP  # From Quest 3 browser

# Check firewall
sudo ufw status
sudo iptables -L
```

### Performance Issues
- **Reduce bitrate** if experiencing lag
- **Lower resolution** if frames drop
- **Check WiFi signal strength** on Quest 3
- **Close other network-heavy applications**

### Audio Issues
- **Check PulseAudio** is running in container
- **Verify audio device** selection in ALVR
- **Test microphone** permissions

## Advanced Configuration

### Custom SteamVR Settings
```bash
# Access SteamVR settings
docker exec -it WolfVRStreaming bash
cd /home/retro/.steam/steam/config
# Edit steamvr.vrsettings
```

### Multiple Headsets
- Each headset needs separate ALVR client
- Configure different ports for each session
- Use multiple Wolf apps if needed

### Performance Monitoring
```bash
# Monitor VR performance
docker exec -it WolfVRStreaming bash
/home/retro/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrmonitor
```

## Alternative Solutions

### If ALVR doesn't work well:
1. **Virtual Desktop** (paid Quest app)
2. **Oculus Link** (USB cable connection)
3. **Steam Link VR** (experimental)

### For other headsets:
- **Valve Index**: Direct connection via DisplayPort
- **Vive**: SteamVR with Lighthouse tracking
- **WMR headsets**: Use Monado OpenXR runtime

## Useful Commands

```bash
# Restart ALVR server
docker restart WolfVRStreaming

# Check ALVR logs
docker logs WolfVRStreaming

# Access container shell
docker exec -it WolfVRStreaming bash

# Monitor network traffic
sudo tcpdump -i any port 9943

# Check VR runtime
echo $XR_RUNTIME_JSON
```

## Support and Community

- **ALVR Discord**: [https://discord.gg/ALVR](https://discord.gg/ALVR)
- **ALVR GitHub**: [https://github.com/alvr-org/ALVR](https://github.com/alvr-org/ALVR)
- **Games on Whales Discord**: [Discord invite from repository]
- **r/VRGaming**: Reddit community for VR gaming

## Next Steps

1. **Test basic VR functionality** with The Lab
2. **Optimize settings** for your network and hardware
3. **Install your favorite VR games**
4. **Experiment with different apps** (Firefox VR, Blender VR, etc.)
5. **Consider multiple headsets** for multiplayer VR

Happy VR gaming! 🥽🎮
