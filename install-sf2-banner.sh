#!/usr/bin/env bash
# install-sf2-banner.sh — FIXED tmp handling
set -euo pipefail
OWNER="AirysDark"
REPO="SourceForge-2.0-banner"
BRANCH="main"
DO_MOTD="yes"
UNINSTALL="no"
LOCAL_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="${2:?}"; shift 2;;
    --repo) REPO="${2:?}"; shift 2;;
    --branch) BRANCH="${2:?}"; shift 2;;
    --no-motd) DO_MOTD="no"; shift;;
    --motd) DO_MOTD="yes"; shift;;
    --uninstall) UNINSTALL="yes"; shift;;
    --local) LOCAL_PATH="${2:?}"; shift 2;;
    -h|--help) sed -n '1,120p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

require_root() { [[ $EUID -eq 0 ]] || { echo "Please run as root (sudo)."; exit 1; }; }
exists() { command -v "$1" >/dev/null 2>&1; }

fetch() {
  local rel="$1" dest="$2"
  local base="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
  curl -fsSL "${base}/${rel}" -o "${dest}"
}

install_files_from_local() {
  local src="$1"
  install -m 0755 -D "${src}/sf2-banner" /usr/local/bin/sf2-banner
  mkdir -p /usr/lib/sf2/banner.d
  find "${src}/banner.d" -maxdepth 1 -type f -name "*.sh" -print0 | while IFS= read -r -d '' f; do
    install -m 0755 -D "$f" "/usr/lib/sf2/banner.d/$(basename "$f")"
  done
}

install_files_from_github() {
  tmp="$(mktemp -d)"
  # master
  fetch "sf2-banner" "/usr/local/bin/sf2-banner"
  chmod 0755 /usr/local/bin/sf2-banner
  # plugins
  mkdir -p /usr/lib/sf2/banner.d
  for f in 10-hostname.sh 20-uptime.sh 30-ip.sh 40-load.sh 50-ram.sh 60-disk.sh; do
    fetch "banner.d/${f}" "$tmp/$f"
    install -m 0755 -D "$tmp/$f" "/usr/lib/sf2/banner.d/$f"
  done
  rm -rf "$tmp"
}

install_motd_hook() {
  mkdir -p /etc/update-motd.d
  cat >/etc/update-motd.d/10-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/update-motd.d/10-sf2-banner
}

remove_motd_hook() { rm -f /etc/update-motd.d/10-sf2-banner 2>/dev/null || true; }

uninstall_all() {
  echo "[SF2] Uninstalling…"
  remove_motd_hook
  rm -f /usr/local/bin/sf2-banner 2>/dev/null || true
  rm -rf /usr/lib/sf2/banner.d 2>/dev/null || true
  echo "[SF2] Uninstall complete."
}

main() {
  require_root
  if [[ "$UNINSTALL" == "yes" ]]; then uninstall_all; exit 0; fi
  mkdir -p /usr/lib/sf2/banner.d /usr/local/bin /etc/sf2 /var/lib/sf2 /run/sf2

  if [[ -n "$LOCAL_PATH" ]]; then
    echo "[SF2] Installing from local path: $LOCAL_PATH"
    install_files_from_local "$LOCAL_PATH"
  else
    echo "[SF2] Installing from GitHub: ${OWNER}/${REPO}@${BRANCH}"
    exists curl || { echo "curl is required. Install it and retry." >&2; exit 1; }
    install_files_from_github
  fi

  if [[ "$DO_MOTD" == "yes" ]]; then
    install_motd_hook
    echo "[SF2] MOTD hook installed."
  else
    remove_motd_hook
    echo "[SF2] MOTD hook disabled."
  fi

  echo; echo "[SF2] Test run:"
  /usr/local/bin/sf2-banner || true
  echo; echo "[SF2] Done."
}
main "$@"
