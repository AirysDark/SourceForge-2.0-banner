#!/usr/bin/env bash
# install-sf2-complete.sh — install/override SF2 banner + commands plugin + cpu helper
set -euo pipefail

OWNER="${OWNER:-AirysDark}"
REPO="${REPO:-SourceForge-2.0-banner}"
BRANCH="${BRANCH:-main}"

require_root() { [[ $EUID -eq 0 ]] || { echo "Run with sudo/root"; exit 1; }; }
exists() { command -v "$1" >/dev/null 2>&1; }
raw() { echo "https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/$1"; }
fetch() { local rel="$1" dest="$2"; curl -fsSL "$(raw "$rel")" -o "$dest"; }

install_all() {
  mkdir -p /usr/local/bin /usr/lib/sf2/banner.d /etc/sf2 /var/lib/sf2 /run/sf2

  # main runner: use local file if present, else fetch
  if [ -f "./sf2-banner" ]; then
    install -m 0755 -D "./sf2-banner" /usr/local/bin/sf2-banner
  else
    fetch "sf2-banner" "/usr/local/bin/sf2-banner"
    chmod 755 /usr/local/bin/sf2-banner
  fi

  # plugins (core + commands): prefer local copies
  core_plugins="10-hostname.sh 20-uptime.sh 30-ip.sh 40-load.sh 50-ram.sh 60-disk.sh 70-commands.sh"
  for f in $core_plugins; do
    if [ -f "./banner.d/$f" ]; then
      install -m 0755 -D "./banner.d/$f" "/usr/lib/sf2/banner.d/$f"
    else
      tmp="$(mktemp)"; fetch "banner.d/$f" "$tmp" || true
      if [ -s "$tmp" ]; then install -m 0755 -D "$tmp" "/usr/lib/sf2/banner.d/$f"; fi
      rm -f "$tmp"
    fi
  done

  # config tool: prefer local
  if [ -f "./sf2-config" ]; then
    install -m 0755 -D "./sf2-config" /usr/local/bin/sf2-config
  else
    tmp="$(mktemp)"; fetch "sf2-config" "$tmp" || true
    [ -s "$tmp" ] && install -m 0755 -D "$tmp" /usr/local/bin/sf2-config
    rm -f "$tmp"
  fi

  # cpu helper: prefer local
  if [ -f "./bin/cpu" ]; then
    install -m 0755 -D "./bin/cpu" /usr/local/bin/cpu
  else
    tmp="$(mktemp)"; fetch "bin/cpu" "$tmp" || true
    [ -s "$tmp" ] && install -m 0755 -D "$tmp" /usr/local/bin/cpu
    rm -f "$tmp"
  fi
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

  echo "[SF2] Installing SourceForge 2.0 banner + commands + cpu helper…"
  install_all
  install_motd
  disable_others
  profile_fallback

  echo "[SF2] Test run:"
  /usr/local/bin/sf2-banner || true
  echo "[SF2] Done."
}
main "$@"
