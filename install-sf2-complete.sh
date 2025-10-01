#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/AirysDark/SourceForge-2.0-banner.git"
INSTALL_DIR="/usr/lib/sf2"
BIN_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/sf2"

echo "──────────────────────────────────────────────"
echo " Installing SourceForge 2.0 Banner (auto-refresh enabled)"
echo "──────────────────────────────────────────────"

sudo mkdir -p "$INSTALL_DIR/banner.d" "$BIN_DIR" "$SHARE_DIR"

# Install scripts
sudo install -m 755 sf2-banner "$BIN_DIR/sf2-banner"
sudo install -m 755 sf2-config "$BIN_DIR/sf2-config"
sudo install -m 755 bin/cpu "$BIN_DIR/cpu"
sudo install -m 755 bin/sf2-software "$BIN_DIR/sf2-software"
sudo install -m 755 usr/local/share/sf2/software-full.sh "$SHARE_DIR/software-full.sh"

# MOTD hook
MOTD_HOOK="/etc/profile.d/sf2-banner.sh"
sudo tee "$MOTD_HOOK" >/dev/null <<'EOF'
#!/bin/sh
sf2-banner
EOF
sudo chmod +x "$MOTD_HOOK"

echo "──────────────────────────────────────────────"
echo " SourceForge 2.0 Banner installed."
echo " Run with: sf2-banner"
echo "──────────────────────────────────────────────"
/usr/local/bin/sf2-banner || true
