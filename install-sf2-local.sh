#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[SF2] Installing from local bundle: $ROOT"
install -m0755 -D "$ROOT/sf2-banner" /usr/local/bin/sf2-banner
install -m0755 -D "$ROOT/sf2-config" /usr/local/bin/sf2-config
install -m0755 -D "$ROOT/bin/cpu" /usr/local/bin/cpu
mkdir -p /usr/lib/sf2/banner.d
install -m0755 "$ROOT"/banner.d/*.sh /usr/lib/sf2/banner.d/
mkdir -p /etc/update-motd.d
cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
chmod +x /etc/update-motd.d/00-sf2-banner
echo "[SF2] Installed."
