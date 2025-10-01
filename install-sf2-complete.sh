#!/usr/bin/env bash
# install-sf2-complete.sh — dual-mode + copies software-full.sh into /usr/local/share/sf2
set -euo pipefail

OWNER="${OWNER:-AirysDark}"; REPO="${REPO:-SourceForge-2.0-banner}"; BRANCH="${BRANCH:-main}"
DO_UPDATE="no"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) DO_UPDATE="yes"; shift;;
    --owner) OWNER="${2:?}"; shift 2;;
    --repo)  REPO="${2:?}"; shift 2;;
    --branch) BRANCH="${2:?}"; shift 2;;
    *) break;;
  esac
done

require_root(){ [[ $EUID -eq 0 ]] || { echo "Run with sudo/root"; exit 1; }; }
raw(){ echo "https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/$1"; }
fetch(){ curl -fsSL "$(raw "$1")" -o "$2"; }
have(){ [ -f "./$1" ]; }

install_file(){ # <src_rel> <dest_abs> <mode>
  src="$1"; dest="$2"; mode="$3"
  mkdir -p "$(dirname "$dest")"
  if have "$src"; then install -m "$mode" -D "./$src" "$dest"
  else tmp="$(mktemp)"; if fetch "$src" "$tmp"; then install -m "$mode" -D "$tmp" "$dest"; else echo "[SF2] WARN: Missing $src (local+remote) — skipping"; fi; rm -f "$tmp"; fi
}

install_all(){
  install_file sf2-banner /usr/local/bin/sf2-banner 755
  install_file sf2-config /usr/local/bin/sf2-config 755
  install_file bin/cpu /usr/local/bin/cpu 755
  install_file bin/sf2-software /usr/local/bin/sf2-software 755

  for f in banner.d/10-hostname.sh banner.d/20-uptime.sh banner.d/30-ip.sh \
           banner.d/40-load.sh banner.d/50-ram.sh banner.d/60-disk.sh banner.d/70-commands.sh; do
    install_file "$f" "/usr/lib/sf2/$f" 755
  done

  # Ensure full menu is installed to where wrapper expects it
  mkdir -p /usr/local/share/sf2

  # Copy from typical repo path #1
  if have usr/local/share/sf2/software-full.sh; then
    install -m 0755 -D ./usr/local/share/sf2/software-full.sh /usr/local/share/sf2/software-full.sh

  # Copy from typical repo path #2 (root)
  elif have software-full.sh; then
    install -m 0755 -D ./software-full.sh /usr/local/share/sf2/software-full.sh

  # Else try fetch from GitHub path usr/local/share/sf2/software-full.sh
  else
    tmp="$(mktemp)"
    if fetch usr/local/share/sf2/software-full.sh "$tmp"; then
      install -m 0755 -D "$tmp" /usr/local/share/sf2/software-full.sh
    else
      echo "[SF2] WARN: software-full.sh not found locally or in repo path — you can add it later to /usr/local/share/sf2/software-full.sh"
    fi
    rm -f "$tmp"
  fi
}

install_motd(){
  mkdir -p /etc/update-motd.d
  cat >/etc/update-motd.d/00-sf2-banner <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/update-motd.d/00-sf2-banner
}
disable_others(){ find /etc/update-motd.d -maxdepth 1 -type f ! -name '00-sf2-banner' -exec chmod -x {} \; 2>/dev/null || true; }
profile_fallback(){
  cat >/etc/profile.d/sf2-banner.sh <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/profile.d/sf2-banner.sh
}

main(){
  require_root
  command -v curl >/dev/null 2>&1 || { echo "curl required"; exit 1; }
  if [[ "$DO_UPDATE" = "yes" ]]; then
    echo "[SF2] Updating components…"; install_all
  else
    echo "[SF2] Installing components…"; install_all; install_motd; disable_others; profile_fallback
  fi
  echo "[SF2] Test run:"; /usr/local/bin/sf2-banner || true; echo "[SF2] Done."
}
main "$@"
