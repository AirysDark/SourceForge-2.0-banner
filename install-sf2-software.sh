#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install -m 0755 -D "$SRC/bin/sf2-software" /usr/local/bin/sf2-software
install -m 0755 -D "$SRC/banner.d/70-commands.sh" /usr/lib/sf2/banner.d/70-commands.sh
mkdir -p /usr/local/share/sf2
# Write the full menu into software-full.sh from heredoc if provided via this installer
if [[ -n "${SF2_SOFTWARE_FULL:-}" ]]; then
  printf "%s" "${SF2_SOFTWARE_FULL}" > /usr/local/share/sf2/software-full.sh
  chmod 0755 /usr/local/share/sf2/software-full.sh
fi
echo "[SF2] sf2-software installed. Add your full menu to /usr/local/share/sf2/software-full.sh"
command -v sf2-banner >/dev/null 2>&1 && sf2-banner || true
