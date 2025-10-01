#!/usr/bin/env bash
set -euo pipefail

echo "──────────────────────────────────────────────"
echo " SourceForge 2.0 Banner Uninstaller"
echo "──────────────────────────────────────────────"

BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

# Remove binaries
for f in sf2-banner sf2-config sf2-software cpu; do
  if [ -f "$BIN/$f" ]; then
    sudo rm -f "$BIN/$f"
    echo "Removed: $BIN/$f"
  fi
done

# Remove shared menus
if [ -d "$SHARE" ]; then
  sudo rm -rf "$SHARE"
  echo "Removed: $SHARE"
fi

# Remove banner plugins
if [ -d "$LIB" ]; then
  sudo rm -rf "$LIB"
  echo "Removed: $LIB"
fi

# Remove MOTD hook
if [ -f "$MOTD" ]; then
  sudo rm -f "$MOTD"
  echo "Removed: $MOTD"
fi

# Remove profile.d hook
if [ -f "$PROFILE" ]; then
  sudo rm -f "$PROFILE"
  echo "Removed: $PROFILE"
fi

echo "──────────────────────────────────────────────"
echo " SF2 Banner fully uninstalled."
echo "──────────────────────────────────────────────"