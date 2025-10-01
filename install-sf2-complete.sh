#!/usr/bin/env bash
# install-sf2-complete.sh — fixed RAM plugin version
set -euo pipefail
OWNER="AirysDark"; REPO="SourceForge-2.0-banner"; BRANCH="main"
DO_UPDATE="no"
[[ "${1:-}" == "--update" ]] && DO_UPDATE="yes"

require_root() { [[ $EUID -eq 0 ]] || { echo "Run with sudo/root"; exit 1; }; }
exists() { command -v "$1" >/dev/null 2>&1; }
raw() { echo "https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/$1"; }
fetch() { curl -fsSL "$(raw "$1")" -o "$2"; }

install_all() {
  mkdir -p /usr/local/bin /usr/lib/sf2/banner.d /etc/sf2
  install -m 0755 -D ./sf2-banner /usr/local/bin/sf2-banner
  install -m 0755 -D ./sf2-config /usr/local/bin/sf2-config
  for f in ./banner.d/*.sh; do install -m 0755 -D "$f" "/usr/lib/sf2/banner.d/$(basename "$f")"; done
  install -m 0755 -D ./bin/cpu /usr/local/bin/cpu
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
  find /etc/update-motd.d -maxdepth 1 -type f ! -name '00-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true
}

main() {
  require_root
  exists curl || { echo "curl required"; exit 1; }
  install_all
  if [[ "$DO_UPDATE" != "yes" ]]; then
    install_motd
    disable_others
  fi
  echo "[SF2] Test run:"
  /usr/local/bin/sf2-banner || true
  echo "[SF2] Done."
}
main "$@"
