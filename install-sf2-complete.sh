#!/usr/bin/env bash
# SourceForge 2.0 Banner — robust installer (works from file OR via curl|bash)
# - Safe when piped: BASH_SOURCE may be unset, so we guard it
# - Installs from current dir if all files exist, otherwise clones repo

# Safe flags: enable -u AFTER we compute SCRIPT_DIR
set -e -o pipefail

# Handle BASH_SOURCE being unset under stdin
SELF="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$SELF")" 2>/dev/null && pwd || echo /tmp)"
set -u

# ----------------------- Config -----------------------
REPO_URL="${REPO_URL:-https://github.com/AirysDark/SourceForge-2.0-banner.git}"
TMP="/tmp/sf2-src"

BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

# ------------------ Source selection ------------------
SRC="$SCRIPT_DIR"
need=(
  sf2-banner
  sf2-config
  bin/sf2-software
  bin/cpu
  usr/local/share/sf2/software-full.sh
)

missing=0
for f in "${need[@]}"; do
  if [ ! -f "$SRC/$f" ]; then
    missing=1
  fi
done

if [ "$missing" -eq 1 ]; then
  echo "──────────────────────────────────────────────"
  echo " Installing SourceForge 2.0 Banner (from repo)"
  echo "──────────────────────────────────────────────"
  command -v git >/dev/null 2>&1 || {
    sudo apt-get update -y >/dev/null 2>&1 || true
    sudo apt-get install -y git >/dev/null 2>&1
  }
  rm -rf "$TMP"
  git clone --depth 1 "$REPO_URL" "$TMP"
  SRC="$TMP"
else
  echo "──────────────────────────────────────────────"
  echo " Installing SourceForge 2.0 Banner (local dir)"
  echo "──────────────────────────────────────────────"
fi

# ----------------------- Install -----------------------
sudo mkdir -p "$BIN" "$LIB/banner.d" "$SHARE"

sudo install -m0755 "$SRC/sf2-banner"               "$BIN/sf2-banner"
sudo install -m0755 "$SRC/sf2-config"               "$BIN/sf2-config"
sudo install -m0755 "$SRC/bin/sf2-software"         "$BIN/sf2-software"
sudo install -m0755 "$SRC/bin/cpu"                  "$BIN/cpu"
sudo install -m0755 "$SRC/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"

# Optional plugins directory support if present
if compgen -G "$SRC/banner.d/*.sh" >/dev/null 2>&1; then
  sudo install -m0755 "$SRC"/banner.d/*.sh "$LIB/banner.d/"
fi

# --------------------- MOTD hook -----------------------
sudo tee "$MOTD" >/dev/null <<'HOOK'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
HOOK
sudo chmod +x "$MOTD"

# --------------- Profile.d fallback hook ---------------
# Shown for logins where pam_motd isn't used (e.g. some shells/tty)
sudo tee "$PROFILE" >/dev/null <<'PROFILE'
#!/bin/sh
# Only on interactive shells; avoid double-print on SSH sessions that already use MOTD
case "$-" in
  *i*) [ -x /usr/local/bin/sf2-banner ] && [ -z "${SSH_TTY:-}" ] && /usr/local/bin/sf2-banner ;;
esac
PROFILE
sudo chmod +x "$PROFILE"

# -------------------- Test run -------------------------
/usr/local/bin/sf2-banner || true

# -------------------- Cleanup tmp ----------------------
[ "$SRC" = "$TMP" ] && rm -rf "$TMP" || true

echo "──────────────────────────────────────────────"
echo " Done."
echo "──────────────────────────────────────────────"