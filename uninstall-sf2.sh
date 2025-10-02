#!/usr/bin/env bash
# SourceForge 2.0 Banner — Uninstaller
set -euo pipefail

say(){ printf '%s\n' "$*"; }
say "──────────────────────────────────────────────"
say " Uninstalling SourceForge 2.0 Banner"
say "──────────────────────────────────────────────"

# Remove wrappers/real binaries if present
sudo rm -f /usr/local/bin/.sf2-config-real /usr/local/bin/.sf2-software-real || true

# Remove public commands
sudo rm -f /usr/local/bin/sf2-banner
sudo rm -f /usr/local/bin/sf2-config
sudo rm -f /usr/local/bin/sf2-software
sudo rm -f /usr/local/bin/cpu

# Remove shared menu file if installed
sudo rm -f /usr/local/share/sf2/software-full.sh

# Remove MOTD and profile hooks
sudo rm -f /etc/update-motd.d/00-sf2-banner
sudo rm -f /etc/profile.d/00-sf2-banner.sh

# Remove plugins + colors
sudo rm -rf /usr/lib/sf2

say "──────────────────────────────────────────────"
say " Removed."
say "──────────────────────────────────────────────"