#!/usr/bin/env bash
# install-sf2-banner-override.sh — force SF2 to override DietPi banner
set -euo pipefail

echo "[SF2] Installing/Overriding DietPi banner..."

# Step 1: Install SF2 from GitHub
curl -fsSL https://raw.githubusercontent.com/AirysDark/SourceForge-2.0-banner/main/install-sf2-banner.sh | sudo bash

# Step 2: Disable DietPi MOTD scripts
sudo find /etc/update-motd.d -maxdepth 1 -type f -iname '*dietpi*' -exec chmod -x {} \; 2>/dev/null || true

# Step 3: Remove/disable ALL other MOTD scripts except SF2
sudo find /etc/update-motd.d -maxdepth 1 -type f ! -name '10-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true

# Step 4: Rename SF2 banner to 00-sf2-banner (highest priority)
if [ -f /etc/update-motd.d/10-sf2-banner ]; then
  sudo mv /etc/update-motd.d/10-sf2-banner /etc/update-motd.d/00-sf2-banner
fi
echo '#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner' | sudo tee /etc/update-motd.d/00-sf2-banner >/dev/null
sudo chmod +x /etc/update-motd.d/00-sf2-banner

# Step 5: Add profile.d fallback
echo '#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner' | sudo tee /etc/profile.d/sf2-banner.sh >/dev/null
sudo chmod +x /etc/profile.d/sf2-banner.sh

echo "[SF2] Override complete. Test run:"
/usr/local/bin/sf2-banner || true
