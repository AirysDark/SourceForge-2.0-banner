#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/AirysDark/SourceForge-2.0-banner.git"
TMP_DIR="/tmp/sf2-banner-install"
INSTALL_DIR="/usr/lib/sf2"
BIN_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/sf2"

echo "──────────────────────────────────────────────"
echo " [SF2] Installing SourceForge 2.0 Banner (clean style)"
echo "──────────────────────────────────────────────"

# Clean old temp dir
rm -rf "$TMP_DIR"
git clone --depth=1 "$REPO_URL" "$TMP_DIR"

# Create dirs
sudo mkdir -p "$INSTALL_DIR/banner.d" "$BIN_DIR" "$SHARE_DIR"

# Install main scripts
sudo install -m 755 "$TMP_DIR/sf2-banner" "$BIN_DIR/sf2-banner"
sudo install -m 755 "$TMP_DIR/sf2-config" "$BIN_DIR/sf2-config"
sudo install -m 755 "$TMP_DIR/bin/cpu" "$BIN_DIR/cpu"
sudo install -m 755 "$TMP_DIR/bin/sf2-software" "$BIN_DIR/sf2-software"

# Install full software menu
sudo mkdir -p "$SHARE_DIR"
sudo install -m 755 "$TMP_DIR/usr/local/share/sf2/software-full.sh" "$SHARE_DIR/software-full.sh"

# Install plugins
sudo cp -a "$TMP_DIR/banner.d/"* "$INSTALL_DIR/banner.d/"
sudo chmod +x "$INSTALL_DIR/banner.d/"*.sh

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