#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-/}"
echo "Installing SourceForge 2.0 Banner to ${ROOT}"

fix_mode() { sed -i 's/\r$//' "$1" 2>/dev/null || true; chmod "$2" "$1" || true; }

cp -a usr "$ROOT/"
cp -a etc "$ROOT/"

fix_mode "${ROOT}/usr/local/bin/sf2-banner" 0755
fix_mode "${ROOT}/usr/local/bin/sf2-config" 0755
fix_mode "${ROOT}/usr/local/bin/sf2-software" 0755
fix_mode "${ROOT}/usr/local/bin/cpu" 0755
fix_mode "${ROOT}/usr/local/share/sf2/software-full.sh" 0755
fix_mode "${ROOT}/etc/update-motd.d/00-sf2-banner" 0755
fix_mode "${ROOT}/etc/profile.d/00-sf2-banner.sh" 0755
chmod 0644 "${ROOT}/usr/lib/sf2/banner.d/50-ram.sh" 2>/dev/null || true

echo "Done. Run: sf2-banner"
