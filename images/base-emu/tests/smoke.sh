#!/usr/bin/env bash
# Smoke test for base-emu -- adds retroarch and a pile of emulator
# AppImages downloaded at build time. We only spot-check that the downloads
# landed and the launcher scripts are in place; actually booting an
# emulator needs a display + ROMs.

source /smoke-common/lib.sh

assert_has retroarch ffmpeg

# Emulator AppImages fetched at build time. If a GitHub release URL ever
# 404s, the AppImage is missing here -- a silent failure at image-build
# time we want to catch.
for app in pcsx2-emu.AppImage xemu-emu.AppImage rpcs3-emu.AppImage \
           cemu-emu.AppImage dolphin-emu.AppImage; do
  assert_path "/Applications/$app"
done

# Xenia is downloaded as a tarball and extracted.
assert_path /Applications/xenia-canary

# Launcher shims on PATH (added via ENV PATH in the Dockerfile).
assert_path /Applications/launchers

# Mount points the Wolf config wires ROM/BIOS volumes onto.
assert_path /bioses /ROMs

smoke_report
