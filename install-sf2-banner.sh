#!/usr/bin/env bash
# install-sf2-banner.sh — SourceForge 2.0 Banner installer
# Usage:
#   sudo bash install-sf2-banner.sh [--zip /path/to/sf2-full-scrub.zip] [--no-motd] [--motd] [--uninstall]
# Defaults:
#   - If --zip is omitted, expects files laid out like:
#       ./usr/local/bin/sf2-banner
#       ./usr/lib/sf2/banner.d/*.sh
set -euo pipefail

ZIP=""
DO_MOTD="yes"
UNINSTALL="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --zip) ZIP="${2-}"; shift 2;;
    --no-motd) DO_MOTD="no"; shift;;
    --motd) DO_MOTD="yes"; shift;;
    --uninstall) UNINSTALL="yes"; shift;;
    -h|--help)
      sed -n '1,30p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

require_root() {
  if [[ ${EUID} -ne 0 ]]; then
    echo "Please run as root (sudo)." >&2
    exit 1
  fi
}

exists() { command -v "$1" >/dev/null 2>&1; }

make_dirs() {
  mkdir -p /usr/lib/sf2/banner.d
  mkdir -p /usr/local/bin
  mkdir -p /etc/sf2
  mkdir -p /var/lib/sf2
  mkdir -p /run/sf2
}

install_files_from_tree() {
  local src_root="$1"
  # binaries
  install -m 0755 -D "${src_root}/usr/local/bin/sf2-banner" /usr/local/bin/sf2-banner
  # plugins
  install -m 0755 -D "${src_root}/usr/lib/sf2/banner.d" /usr/lib/sf2/banner.d
  find "${src_root}/usr/lib/sf2/banner.d" -type f -name '*.sh' -exec install -m 0755 -D "{}" "/usr/lib/sf2/banner.d/$(basename "{}")" \;
}

install_motd_hook() {
  # Debian/Ubuntu PAM MOTD
  mkdir -p /etc/update-motd.d
  cat >/etc/update-motd.d/10-sf2-banner <<'EOF'
#!/bin/sh
# MOTD hook for SourceForge 2.0 banner
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
  chmod +x /etc/update-motd.d/10-sf2-banner
}

remove_motd_hook() {
  rm -f /etc/update-motd.d/10-sf2-banner 2>/dev/null || true
}

uninstall_all() {
  echo "[SF2] Uninstalling…"
  remove_motd_hook
  rm -f /usr/local/bin/sf2-banner 2>/dev/null || true
  rm -rf /usr/lib/sf2/banner.d 2>/dev/null || true
  # Keep /etc/sf2, /var/lib/sf2, /run/sf2 (they might be used by other SF2 tools)
  echo "[SF2] Uninstall complete."
}

main() {
  require_root

  if [[ "$UNINSTALL" == "yes" ]]; then
    uninstall_all
    exit 0
  fi

  workdir="$(mktemp -d)"
  trap 'rm -rf "$workdir"' EXIT

  if [[ -n "$ZIP" ]]; then
    echo "[SF2] Installing from ZIP: $ZIP"
    if ! exists unzip; then
      echo "[SF2] Installing unzip…" >&2
      if exists apt-get; then
        apt-get update -y >/dev/null 2>&1 || true
        apt-get install -y unzip >/dev/null
      else
        echo "Please install 'unzip' or extract manually." >&2
        exit 1
      fi
    end if
    fi
    unzip -q "$ZIP" -d "$workdir"
    # Try common top-level folder or root
    if [[ -d "$workdir/usr/local/bin" ]]; then
      src_root="$workdir"
    else
      # find the folder containing usr/local/bin
      src_root="$(find "$workdir" -type d -path '*/usr/local/bin' -printf '%h\n' | head -n1 || true)"
      if [[ -z "$src_root" ]]; then
        echo "Cannot locate usr/local/bin in the ZIP." >&2
        exit 1
      fi
    fi
  else
    echo "[SF2] Installing from current tree."
    src_root="."
  fi

  make_dirs
  install_files_from_tree "$src_root"
  echo "[SF2] Installed /usr/local/bin/sf2-banner and plugins."

  if [[ "$DO_MOTD" == "yes" ]]; then
    install_motd_hook
    echo "[SF2] MOTD hook installed at /etc/update-motd.d/10-sf2-banner"
  else
    remove_motd_hook
    echo "[SF2] MOTD hook disabled."
  fi

  echo
  echo "[SF2] Test run:"
  /usr/local/bin/sf2-banner || true
  echo
  echo "[SF2] Done."
}

main "$@"