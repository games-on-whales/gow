# Building Your Custom Containers Guide

This guide will help you build your custom containers and configure Wolf to use your GitHub repository.

## 1. Repository Configuration

Your repository is already configured to work! The GitHub Actions workflow automatically detects that this is a fork and will:

- **Build containers** to `ghcr.io/devilblader87/gow/<image-name>`
- **Use proper namespace** for your containers
- **Support pull requests** and branch builds

## 2. Container Image Naming

Your built containers will be available as:
```
ghcr.io/devilblader87/gow/base:edge
ghcr.io/devilblader87/gow/base-app:edge
ghcr.io/devilblader87/gow/xfce:edge
ghcr.io/devilblader87/gow/vr-steamvr:edge
... and so on
```

## 3. Building Containers

### Method 1: Automatic via GitHub Actions (Recommended)

1. **Push changes** to your repository:
   ```bash
   git add .
   git commit -m "Add VR streaming support"
   git push origin main
   ```

2. **GitHub Actions will automatically**:
   - Build all modified containers
   - Push to GitHub Container Registry
   - Make them available for Wolf

3. **Check build status**:
   - Go to your repository on GitHub
   - Click "Actions" tab
   - Monitor the build progress

### Method 2: Manual Local Build

For quick testing or development:

```bash
# Build a specific container locally
docker build -t ghcr.io/devilblader87/gow/vr-steamvr:edge \
  --build-arg BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge \
  apps/vr-steamvr/build

# Test the container
docker run --rm -it ghcr.io/devilblader87/gow/vr-steamvr:edge bash
```

### Method 3: Build All Containers

```bash
# Build base images first
docker build -t ghcr.io/devilblader87/gow/base:edge images/base/build
docker build -t ghcr.io/devilblader87/gow/base-app:edge \
  --build-arg BASE_IMAGE=ghcr.io/devilblader87/gow/base:edge \
  images/base-app/build

# Build app containers
for app in apps/*; do
  if [ -d "$app/build" ]; then
    app_name=$(basename "$app")
    echo "Building $app_name..."
    docker build -t "ghcr.io/devilblader87/gow/$app_name:edge" \
      --build-arg BASE_APP_IMAGE=ghcr.io/devilblader87/gow/base-app:edge \
      "$app/build"
  fi
done
```

## 4. Updating Wolf Configuration

### Update All Apps to Use Your Repository

Update your `config.toml` to use your built containers:

#### Option 1: Automatic Update (Recommended)
```bash
# Run the update script (in your gow directory)
chmod +x bin/update-wolf-config.sh
./bin/update-wolf-config.sh
```

#### Option 2: Manual Update
Edit `/home/retro/config.toml` and change all image references:
```toml
# Before:
image = 'ghcr.io/games-on-whales/xfce:edge'

# After:
image = 'ghcr.io/devilblader87/gow/xfce:edge'
```

#### Option 3: Add VR App
Add the VR streaming app to your config:
```bash
# Append VR app configuration
cat VR_APP_CONFIG.toml >> /home/retro/config.toml
```

## 5. Building Process Step-by-Step

### Step 1: Prepare Your Changes
```bash
# Add your VR container
git add apps/vr-steamvr/

# Add any other modifications
git add .

# Commit changes
git commit -m "Add VR streaming support with ALVR + SteamVR"
```

### Step 2: Push to Trigger Builds
```bash
# Push to your repository
git push origin main
```

### Step 3: Monitor Build Progress
1. Go to `https://github.com/Devilblader87/gow/actions`
2. Watch the "Automated builds" workflow
3. Wait for all containers to build successfully

### Step 4: Update Wolf Configuration
```bash
# Update config to use your containers
./bin/update-wolf-config.sh

# Restart Wolf server
sudo systemctl restart wolf  # or however you run Wolf
```

### Step 5: Test Your VR Setup
1. **Connect via Moonlight** to your Wolf server
2. **Look for "VR Streaming"** in the app list
3. **Launch the VR app** - it should start ALVR + SteamVR
4. **Configure ALVR** via web interface at `http://SERVER_IP:8082`

## 6. Container Development Workflow

### For Existing Containers
```bash
# 1. Edit container
vim apps/steam/build/Dockerfile

# 2. Test locally (optional)
docker build -t test-steam apps/steam/build

# 3. Push to trigger auto-build
git add apps/steam/
git commit -m "Update Steam container"
git push

# 4. Wait for GitHub Actions to build
# 5. Update Wolf config if needed
```

### For New Containers
```bash
# 1. Create new app directory
mkdir -p apps/my-new-app/{assets,build/scripts,build/configs}

# 2. Create wolf.config.toml
vim apps/my-new-app/assets/wolf.config.toml

# 3. Create Dockerfile
vim apps/my-new-app/build/Dockerfile

# 4. Add to build system
git add apps/my-new-app/
git commit -m "Add new app: my-new-app"
git push

# 5. Update Wolf config with new app
```

## 7. Advanced Configuration

### Custom Base Images
If you want to modify base images:
```bash
# Edit base image
vim images/base/build/Dockerfile

# This will trigger rebuild of ALL containers
git push
```

### Registry Authentication
Your containers are public by default. For private repositories:
```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull private containers
docker pull ghcr.io/devilblader87/gow/my-private-app:edge
```

### Multi-Platform Builds
Your repository supports AMD64 by default. For ARM64:
```bash
# Edit .github/workflows/auto-build.yml
# Change platforms: "linux/amd64" to "linux/amd64,linux/arm64"
```

## 8. Troubleshooting

### Build Failures
1. **Check GitHub Actions logs**:
   - Go to Actions tab
   - Click on failed workflow
   - Examine error messages

2. **Common issues**:
   - Missing dependencies in Dockerfile
   - Invalid TOML syntax in wolf.config.toml
   - Base image not available

### Container Pull Failures
```bash
# Check if container exists
docker pull ghcr.io/devilblader87/gow/vr-steamvr:edge

# Check Wolf logs
journalctl -u wolf -f

# Verify container registry permissions
```

### VR Specific Issues
1. **ALVR won't start**: Check GPU drivers and permissions
2. **Network connectivity**: Verify ports 8082, 9943, 9944 are open
3. **Quest 3 won't connect**: Ensure same WiFi network

## 9. Contributing Back

Once you have working containers:
1. **Fork the original repository**: `games-on-whales/gow`
2. **Create a pull request** with your VR improvements
3. **Help the community** by sharing your VR setup

## 10. Quick Reference

### Important Files
- `apps/*/assets/wolf.config.toml` - Wolf app configuration
- `apps/*/build/Dockerfile` - Container build instructions
- `.github/workflows/auto-build.yml` - CI/CD pipeline
- `/home/retro/config.toml` - Wolf server configuration

### Important Commands
```bash
# Update Wolf config to use your containers
./bin/update-wolf-config.sh

# Build single container locally
docker build -t my-app apps/my-app/build

# Check container logs
docker logs WolfVRStreaming

# Monitor builds
gh workflow view --repo Devilblader87/gow
```

### Container URLs
Your containers will be available at:
- `ghcr.io/devilblader87/gow/<app-name>:edge`
- Web interface: `https://github.com/users/Devilblader87/packages`

Happy building! 🚀🎮