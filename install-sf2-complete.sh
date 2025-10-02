#!/usr/bin/env bash
set -euo pipefail

# Directories
BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

echo "──────────────────────────────────────────────"
echo " Installing SourceForge 2.0 Banner (with plugins)"
echo "──────────────────────────────────────────────"

# Ensure dirs
sudo mkdir -p "$BIN" "$LIB/banner.d" "$SHARE"

# Install main scripts
sudo install -m0755 sf2-banner "$BIN/sf2-banner"
sudo install -m0755 sf2-config "$BIN/sf2-config"
sudo install -m0755 bin/sf2-software "$BIN/sf2-software"
sudo install -m0755 bin/cpu "$BIN/cpu"
sudo install -m0755 usr/local/share/sf2/software-full.sh "$SHARE/software-full.sh"

# Install colors + plugins
sudo install -m0755 usr/lib/sf2/colors.sh "$LIB/colors.sh"
sudo install -m0755 usr/lib/sf2/banner.d/*.sh "$LIB/banner.d/"

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

echo "──────────────────────────────────────────────"
echo " Installation complete!"
echo " Run: sf2-banner"
echo "──────────────────────────────────────────────"