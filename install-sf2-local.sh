#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[SF2] Installing from local bundle: $root"

install -m0755 -D "$root/sf2-banner" /usr/local/bin/sf2-banner
install -m0755 -D "$root/sf2-config" /usr/local/bin/sf2-config
[ -f "$root/bin/cpu" ] && install -m0755 -D "$root/bin/cpu" /usr/local/bin/cpu || true
[ -f "$root/bin/sf2-software" ] && install -m0755 -D "$root/bin/sf2-software" /usr/local/bin/sf2-software || true

if [ -f "$root/usr/local/share/sf2/software-full.sh" ]; then
  install -m0755 -D "$root/usr/local/share/sf2/software-full.sh" /usr/local/share/sf2/software-full.sh
fi

mkdir -p /usr/lib/sf2/banner.d
if ls "$root"/banner.d/*.sh >/dev/null 2>&1; then
  install -m0755 "$root"/banner.d/*.sh /usr/lib/sf2/banner.d/
fi

mkdir -p /etc/update-motd.d
cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
chmod +x /etc/update-motd.d/00-sf2-banner

echo "[SF2] Test run:"
/usr/local/bin/sf2-banner || true
echo "[SF2] Done."
