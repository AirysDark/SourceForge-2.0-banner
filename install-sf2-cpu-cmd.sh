#!/usr/bin/env bash
# install-sf2-cpu-cmd.sh — add CPU command + commands plugin

set -euo pipefail
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_PLUGIN="/usr/lib/sf2/banner.d/70-commands.sh"
DEST_CPU="/usr/local/bin/cpu"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install-sf2-cpu-cmd.sh" >&2
  exit 1
fi

install -m 0755 -D "$SRC_DIR/banner.d/70-commands.sh" "$DEST_PLUGIN"
install -m 0755 -D "$SRC_DIR/bin/cpu" "$DEST_CPU"

echo "[SF2] Installed updated commands plugin + cpu helper"
sf2-banner || true
