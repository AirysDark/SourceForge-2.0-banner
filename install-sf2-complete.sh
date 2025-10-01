#!/usr/bin/env bash
set -euo pipefail
OWNER="${OWNER:-AirysDark}"; REPO="${REPO:-SourceForge-2.0-banner}"; BRANCH="${BRANCH:-main}"
WORKDIR="/tmp/sf2-banner-install"

[ "$EUID" -eq 0 ] || { echo "[SF2] Run with sudo/root."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "[SF2] Installing git…"; apt-get update -y >/dev/null 2>&1 || true; apt-get install -y git >/dev/null 2>&1; }

install_file ./sf2-banner /usr/local/bin/sf2-banner 755
echo "[SF2] Cloning https://github.com/${OWNER}/${REPO}.git@${BRANCH} …"
rm -rf "$WORKDIR"
git clone --depth 1 --branch "$BRANCH" "https://github.com/${OWNER}/${REPO}.git" "$WORKDIR" >/dev/null
cd "$WORKDIR"

install -m0755 -D sf2-banner /usr/local/bin/sf2-banner
install -m0755 -D sf2-config /usr/local/bin/sf2-config
install -m0755 -D bin/cpu /usr/local/bin/cpu || true
install -m0755 -D bin/sf2-software /usr/local/bin/sf2-software || true
install -m0755 -D usr/local/share/sf2/software-full.sh /usr/local/share/sf2/software-full.sh || true

mkdir -p /usr/lib/sf2/banner.d
if ls banner.d/*.sh >/dev/null 2>&1; then
  install -m0755 banner.d/*.sh /usr/lib/sf2/banner.d/
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
