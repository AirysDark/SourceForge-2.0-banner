#!/usr/bin/env bash
# install-sf2-complete.sh — includes RAM plugin using /proc/meminfo
set -euo pipefail
require_root() { [[ $EUID -eq 0 ]] || { echo "Run with sudo/root"; exit 1; }; }
require_root
mkdir -p /usr/local/bin /usr/lib/sf2/banner.d /etc/sf2 /var/lib/sf2 /run/sf2

install -m 0755 -D ./sf2-banner /usr/local/bin/sf2-banner
install -m 0755 -D ./sf2-config /usr/local/bin/sf2-config
for f in ./banner.d/*.sh; do install -m 0755 -D "$f" "/usr/lib/sf2/banner.d/$(basename "$f")"; done
install -m 0755 -D ./bin/cpu /usr/local/bin/cpu

mkdir -p /etc/update-motd.d
cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
chmod +x /etc/update-motd.d/00-sf2-banner

# Disable other MOTD snippets so SF2 is the only one
find /etc/update-motd.d -maxdepth 1 -type f ! -name '00-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true

echo "[SF2] Test run:"
/usr/local/bin/sf2-banner || true
echo "[SF2] Done."
