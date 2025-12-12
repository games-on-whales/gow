#!/usr/bin/env bash
set -e

source /opt/gow/bash-lib/utils.sh

# --- Unified Unigine Benchmark Installer ---
function unigine_install() {
  local name="$1"
  local url="$2"
  local install_dir="$3"
  local force_reinstall="$4"
  local run_file="/tmp/${name}.run"

  if [[ ! -f "$install_dir/.installed" ]] || [[ "$force_reinstall" -ne 0 ]]; then
    curl -fSL "$url" -o "$run_file"
    chmod +x "$run_file"
    "$run_file" --target "$install_dir"
    rm -f "$run_file"
    touch "$install_dir/.installed"
  else
    gow_log "Unigine $name is already installed."
  fi
}

# --- Install Functions ---
export HEAVEN_FORCE_REINSTALL="${FORCE_REINSTALL:-0}"
export HEAVEN_INSTALL_DIR="$HOME/.unigine/heaven"
function install_heaven() {
  unigine_install "Heaven-4.0" \
    "https://assets.unigine.com/d/Unigine_Heaven-4.0.run" \
    "$HEAVEN_INSTALL_DIR" \
    "$HEAVEN_FORCE_REINSTALL"
}

export VALLEY_FORCE_REINSTALL="${FORCE_REINSTALL:-0}"
export VALLEY_INSTALL_DIR="$HOME/.unigine/valley"
function install_valley() {
  unigine_install "Valley-1.0" \
    "https://assets.unigine.com/d/Unigine_Valley-1.0.run" \
    "$VALLEY_INSTALL_DIR" \
    "$VALLEY_FORCE_REINSTALL"
}

export SUPERPOSITION_FORCE_REINSTALL="${FORCE_REINSTALL:-0}"
export SUPERPOSITION_INSTALL_DIR="$HOME/.unigine/superposition"
function install_superposition() {
  unigine_install "Superposition-1.0" \
    "https://assets.unigine.com/d/Unigine_Superposition-1.0.run" \
    "$SUPERPOSITION_INSTALL_DIR" \
    "$SUPERPOSITION_FORCE_REINSTALL"
}

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

# Enable MangoHud with detailed preset
if [[ -f "$HOME/.config/MangoHud/MangoHud.conf" ]]; then
  gow_log "MangoHud.conf is already present, prioritizing existing configuration."
else
  gow_log "Configuring MangoHud for Unigine Benchmark."
  export MANGOHUD_CONFIGFILE=$(mktemp /tmp/mangohud.XXXXXXXX)
  mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
  echo "position=bottom-left" > "$MANGOHUD_CONFIGFILE"
  echo "preset=4" >> "$MANGOHUD_CONFIGFILE"
  echo "gpu_voltage" >> "$MANGOHUD_CONFIGFILE"
fi

gow_log "[start] Downloading and installing Unigine Benchmark installer"

source /opt/gow/launch-comp.sh

export UNIGINE_BENCHMARK="${UNIGINE_BENCHMARK:-heaven}"  # default to heaven if not set

case "$UNIGINE_BENCHMARK" in
  heaven)
    install_heaven
    launcher "/opt/gow/run-benchmark.sh" "heaven"
    ;;
  valley)
    install_valley
    launcher "/opt/gow/run-benchmark.sh" "valley"
    ;;
  superposition)
    install_superposition
    launcher "/opt/gow/run-benchmark.sh" "superposition"
    ;;
  *)
    gow_log "ERROR: Unknown UNIGINE_BENCHMARK=$UNIGINE_BENCHMARK."
    exit 1
    ;;
esac
