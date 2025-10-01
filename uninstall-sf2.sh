#!/usr/bin/env bash
set -euo pipefail

echo "----------------------------------------------"
echo " SourceForge 2.0 Banner Uninstaller"
echo "----------------------------------------------"

BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

for f in sf2-banner sf2-config sf2-software cpu; do
  if [ -f "$BIN/$f" ]; then sudo rm -f "$BIN/$f"; echo "Removed: $BIN/$f"; fi
done

if [ -d "$SHARE" ]; then sudo rm -rf "$SHARE"; echo "Removed: $SHARE"; fi
if [ -d "$LIB" ]; then sudo rm -rf "$LIB"; echo "Removed: $LIB"; fi
[ -f "$MOTD" ] && { sudo rm -f "$MOTD"; echo "Removed: $MOTD"; }
[ -f "$PROFILE" ] && { sudo rm -f "$PROFILE"; echo "Removed: $PROFILE"; }

echo "----------------------------------------------"
echo " Uninstall complete."
echo "----------------------------------------------"
