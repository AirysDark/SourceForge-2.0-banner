#!/usr/bin/env bash
# SourceForge 2.0 — clone-and-install
set -euo pipefail

OWNER="${OWNER:-AirysDark}"
REPO="${REPO:-SourceForge-2.0-banner}"
BRANCH="${BRANCH:-main}"
WORKDIR="/tmp/sf2-banner-install"

need_root() { [ "$EUID" -eq 0 ] || { echo "[SF2] Run with sudo/root."; exit 1; }; }
have() { command -v "$1" >/dev/null 2>&1; }

need_root
have git || { echo "[SF2] Installing git…"; apt-get update -y >/dev/null 2>&1 || true; apt-get install -y git >/dev/null 2>&1; }

echo "[SF2] Cloning https://github.com/${OWNER}/${REPO}.git@${BRANCH} …"
rm -rf "$WORKDIR"
git clone --depth 1 --branch "$BRANCH" "https://github.com/${OWNER}/${REPO}.git" "$WORKDIR" >/dev/null
cd "$WORKDIR"

echo "[SF2] Installing components…"
install -m 0755 -D sf2-banner                       /usr/local/bin/sf2-banner
install -m 0755 -D sf2-config                       /usr/local/bin/sf2-config
install -m 0755 -D bin/cpu                          /usr/local/bin/cpu
install -m 0755 -D bin/sf2-software                 /usr/local/bin/sf2-software
install -m 0755 -D usr/local/share/sf2/software-full.sh /usr/local/share/sf2/software-full.sh

mkdir -p /usr/lib/sf2/banner.d
install -m 0755 banner.d/*.sh /usr/lib/sf2/banner.d/

# MOTD hook
mkdir -p /etc/update-motd.d
cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
chmod +x /etc/update-motd.d/00-sf2-banner
# Optional: disable other MOTD snippets
find /etc/update-motd.d -maxdepth 1 -type f ! -name '00-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true

echo "[SF2] Test run:"
/usr/local/bin/sf2-banner || true
echo "[SF2] Done."