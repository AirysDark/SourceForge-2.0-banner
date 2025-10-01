#!/usr/bin/env bash
# install-sf2-banner-override.sh — force SF2 to override DietPi banner, with --update
set -euo pipefail

OWNER="${OWNER:-AirysDark}"
REPO="${REPO:-SourceForge-2.0-banner}"
BRANCH="${BRANCH:-main}"

DO_UPDATE="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) DO_UPDATE="yes"; shift;;
    --owner) OWNER="${2:?}"; shift 2;;
    --repo)  REPO="${2:?}"; shift 2;;
    --branch) BRANCH="${2:?}"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

require_root() { [[ $EUID -eq 0 ]] || { echo "Please run as root (sudo)."; exit 1; }; }
exists() { command -v "$1" >/dev/null 2>&1; }
raw() { echo "https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/$1"; }

fetch() { local rel="$1" dest="$2"; curl -fsSL "$(raw "$rel")" -o "$dest"; }

install_or_update() {
  mkdir -p /usr/local/bin /usr/lib/sf2/banner.d /etc/sf2 /var/lib/sf2 /run/sf2
  fetch "sf2-banner" "/usr/local/bin/sf2-banner"
  chmod 0755 /usr/local/bin/sf2-banner

  for f in 10-hostname.sh 20-uptime.sh 30-ip.sh 40-load.sh 50-ram.sh 60-disk.sh; do
    tmp="$(mktemp)"
    fetch "banner.d/${f}" "$tmp"
    install -m 0755 -D "$tmp" "/usr/lib/sf2/banner.d/$f"
    rm -f "$tmp"
  done
}

install_motd() {
  mkdir -p /etc/update-motd.d
  cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/update-motd.d/00-sf2-banner
}

disable_others() {
  find /etc/update-motd.d -maxdepth 1 -type f -iname '*dietpi*' -exec chmod -x {} \; 2>/dev/null || true
  find /etc/update-motd.d -maxdepth 1 -type f ! -name '00-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true
}

profile_fallback() {
  cat >/etc/profile.d/sf2-banner.sh <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/profile.d/sf2-banner.sh
}

main() {
  require_root
  exists curl || { echo "curl required"; exit 1; }

  if [[ "$DO_UPDATE" = "yes" ]]; then
    echo "[SF2] Updating banner + plugins from GitHub…"
    install_or_update
  else
    echo "[SF2] Installing/Overriding DietPi banner…"
    install_or_update
    install_motd
    disable_others
    profile_fallback
  fi

  echo "[SF2] Test run:"
  /usr/local/bin/sf2-banner || true
}

main "$@"
