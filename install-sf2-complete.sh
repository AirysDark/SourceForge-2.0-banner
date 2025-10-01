cat >/tmp/install-sf2-complete.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# ---- resolve where this script lives ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR"
REPO_URL="${REPO_URL:-https://github.com/AirysDark/SourceForge-2.0-banner.git}"
TMP="/tmp/sf2-src"

say() { printf '%s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# If we don't see the files next to the script, fall back to cloning
need_files=( sf2-banner sf2-config bin/sf2-software bin/cpu )
missing=0
for f in "${need_files[@]}"; do
  [ -f "$SRC/$f" ] || missing=1
done
if [ "$missing" -eq 1 ]; then
  say "No local files found; cloning ${REPO_URL}..."
  have git || { say "Installing git..."; sudo apt-get update -y >/dev/null 2>&1 || true; sudo apt-get install -y git >/dev/null 2>&1; }
  rm -rf "$TMP"
  git clone --depth 1 "$REPO_URL" "$TMP"
  SRC="$TMP"
fi

# ---- install paths ----
BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"

sudo mkdir -p "$BIN" "$LIB/banner.d" "$SHARE"

# ---- install mains (if present) ----
[ -f "$SRC/sf2-banner" ] && sudo install -m0755 "$SRC/sf2-banner" "$BIN/sf2-banner"
[ -f "$SRC/sf2-config" ] && sudo install -m0755 "$SRC/sf2-config" "$BIN/sf2-config"
[ -f "$SRC/bin/sf2-software" ] && sudo install -m0755 "$SRC/bin/sf2-software" "$BIN/sf2-software"
[ -f "$SRC/bin/cpu" ] && sudo install -m0755 "$SRC/bin/cpu" "$BIN/cpu"

# optional: software-full.sh (if your build has it)
if [ -f "$SRC/usr/local/share/sf2/software-full.sh" ]; then
  sudo install -m0755 "$SRC/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"
fi

# ---- plugins ----
if compgen -G "$SRC/banner.d/*.sh" >/dev/null 2>&1; then
  sudo install -m0755 "$SRC"/banner.d/*.sh "$LIB/banner.d/"
fi

# ---- MOTD hook (Debian/Ubuntu) ----
sudo tee "$MOTD" >/dev/null <<'HOOK'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
HOOK
sudo chmod +x "$MOTD"

# Also support profile.d for shells that don't use pam_motd
sudo tee /etc/profile.d/00-sf2-banner.sh >/dev/null <<'PROFILE'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && [ -z "$SSH_TTY" ] && /usr/local/bin/sf2-banner
PROFILE
sudo chmod +x /etc/profile.d/00-sf2-banner.sh

say "Install complete."
/usr/local/bin/sf2-banner || true
EOF
sudo bash /tmp/install-sf2-complete.sh