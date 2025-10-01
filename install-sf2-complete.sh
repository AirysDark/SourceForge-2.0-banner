#!/usr/bin/env bash
set -euo pipefail

# Installer that works from current folder or clones repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR"
REPO_URL="${REPO_URL:-https://github.com/AirysDark/SourceForge-2.0-banner.git}"
TMP="/tmp/sf2-src"

BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

need=( sf2-banner sf2-config bin/sf2-software bin/cpu usr/local/share/sf2/software-full.sh )
missing=0
for f in "${need[@]}"; do [ -f "$SRC/$f" ] || missing=1; done
if [ "$missing" -eq 1 ]; then
  command -v git >/dev/null 2>&1 || { sudo apt-get update -y >/dev/null 2>&1 || true; sudo apt-get install -y git >/dev/null 2>&1; }
  rm -rf "$TMP"
  git clone --depth 1 "$REPO_URL" "$TMP"
  SRC="$TMP"
fi

sudo mkdir -p "$BIN" "$LIB/banner.d" "$SHARE"

sudo install -m0755 "$SRC/sf2-banner" "$BIN/sf2-banner"
sudo install -m0755 "$SRC/sf2-config" "$BIN/sf2-config"
sudo install -m0755 "$SRC/bin/sf2-software" "$BIN/sf2-software"
sudo install -m0755 "$SRC/bin/cpu" "$BIN/cpu"
sudo install -m0755 "$SRC/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"

# Optional plugins directory support if present
if compgen -G "$SRC/banner.d/*.sh" >/dev/null 2>&1; then
  sudo install -m0755 "$SRC"/banner.d/*.sh "$LIB/banner.d/"
fi

# MOTD hook
sudo tee "$MOTD" >/dev/null <<'HOOK'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
HOOK
sudo chmod +x "$MOTD"

# Profile hook (for shells without pam_motd)
sudo tee "$PROFILE" >/dev/null <<'PROFILE'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && [ -z "$SSH_TTY" ] && /usr/local/bin/sf2-banner
PROFILE
sudo chmod +x "$PROFILE"

/usr/local/bin/sf2-banner || true
