#!/usr/bin/env bash
set -euo pipefail

echo "──────────────────────────────────────────────"
echo " Uninstalling SourceForge 2.0 Banner"
echo "──────────────────────────────────────────────"

# Remove files
sudo rm -f /usr/local/bin/sf2-banner
sudo rm -f /usr/local/bin/sf2-config
sudo rm -f /usr/local/bin/sf2-software
sudo rm -f /usr/local/bin/cpu
sudo rm -f /usr/local/share/sf2/software-full.sh
sudo rm -f /etc/update-motd.d/00-sf2-banner
sudo rm -f /etc/profile.d/00-sf2-banner.sh

# Remove plugin directory
sudo rm -rf /usr/lib/sf2

echo "──────────────────────────────────────────────"
echo " SourceForge 2.0 Banner removed."
echo "──────────────────────────────────────────────"