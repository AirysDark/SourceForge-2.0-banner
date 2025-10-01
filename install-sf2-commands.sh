#!/usr/bin/env bash
# install-sf2-commands.sh — add the commands section beneath the banner
set -euo pipefail
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="/usr/lib/sf2/banner.d"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install-sf2-commands.sh" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
install -m 0755 -D "$SRC_DIR/banner.d/70-commands.sh" "$DEST_DIR/70-commands.sh"

echo "[SF2] Installed plugin: $DEST_DIR/70-commands.sh"
echo "[SF2] Test run:"
if command -v sf2-banner >/dev/null 2>&1; then
  sf2-banner
else
  echo "sf2-banner not found; plugin will run on next login."
fi
