#!/usr/bin/env bash
set -euo pipefail
echo "Uninstalling SourceForge 2.0 Banner..."
rm -f /usr/local/bin/sf2-banner /usr/local/bin/sf2-config /usr/local/bin/sf2-software /usr/local/bin/cpu
rm -f /etc/update-motd.d/00-sf2-banner /etc/profile.d/00-sf2-banner.sh
rm -rf /usr/local/share/sf2
rm -rf /usr/lib/sf2
echo "Done."
