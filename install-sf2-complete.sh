#!/usr/bin/env bash
set -euo pipefail
echo "[SF2] Installing components…"

# helper to install files
install_file() {
  src="$1"; dest="$2"; mode="${3:-755}"
  if [ -f "$src" ]; then
    install -m "$mode" -D "$src" "$dest"
    echo "[SF2] Installed $dest"
  else
    echo "[SF2] ERROR: missing $src"
  fi
}

# bins
install_file ./sf2-banner /usr/local/bin/sf2-banner 755
install_file ./sf2-config /usr/local/bin/sf2-config 755
install_file ./bin/cpu /usr/local/bin/cpu 755
install_file ./bin/sf2-software /usr/local/bin/sf2-software 755

# full menu
install_file ./usr/local/share/sf2/software-full.sh /usr/local/share/sf2/software-full.sh 755

# plugins
for f in banner.d/*.sh; do
  install_file "$f" "/usr/lib/sf2/banner.d/$(basename "$f")" 755
done

# motd hook
mkdir -p /etc/update-motd.d
cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
chmod +x /etc/update-motd.d/00-sf2-banner

echo "[SF2] Done."