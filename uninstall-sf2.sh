#!/usr/bin/env bash
# SourceForge 2.0 Banner — Uninstaller (incl. tty1 autologin & live dashboard cleanup)
set -euo pipefail

# Use sudo only when not already root
SUDO=""
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then SUDO="sudo"; else
    echo "[SF2] ERROR: Need root privileges (install sudo or run as root)."
    exit 1
  fi
fi

say(){ printf '%s\n' "$*"; }

say "──────────────────────────────────────────────"
say " Uninstalling SourceForge 2.0 Banner"
say "──────────────────────────────────────────────"

# ---------- Stop any live dashboard ----------
# Best-effort: kill watch running sf2-banner or sf2-live
pkill -f 'watch -t -n .* /usr/local/bin/sf2-banner' 2>/dev/null || true
pkill -f '/usr/local/bin/sf2-live' 2>/dev/null || true

# ---------- Remove wrappers/real binaries ----------
$SUDO rm -f /usr/local/bin/.sf2-config-real /usr/local/bin/.sf2-software-real || true

# ---------- Remove public commands ----------
$SUDO rm -f /usr/local/bin/sf2-banner \
             /usr/local/bin/sf2-config \
             /usr/local/bin/sf2-software \
             /usr/local/bin/sf2-live \
             /usr/local/bin/cpu || true

# ---------- Remove shared menu file if installed ----------
$SUDO rm -f /usr/local/share/sf2/software-full.sh || true

# ---------- Remove MOTD and profile hooks ----------
$SUDO rm -f /etc/update-motd.d/00-sf2-banner /etc/profile.d/00-sf2-banner.sh || true

# ---------- Remove plugins + colors ----------
$SUDO rm -rf /usr/lib/sf2 || true

# ---------- Revert tty1 autologin override (if present) ----------
OVR_DIR="/etc/systemd/system/getty@tty1.service.d"
OVR_FILE="$OVR_DIR/override.conf"
if [ -f "$OVR_FILE" ]; then
  $SUDO rm -f "$OVR_FILE"
  $SUDO rmdir "$OVR_DIR" 2>/dev/null || true
  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl daemon-reload || true
    $SUDO systemctl restart getty@tty1.service || true
  fi
  say "Reverted tty1 autologin override."
fi

# ---------- Remove live dashboard autostart from bash_profile ----------
clean_profile() {
  local user="$1"
  local home
  home="$(getent passwd "$user" | cut -d: -f6 || true)"
  [ -n "${home:-}" ] || home="/home/$user"
  local prof="$home/.bash_profile"
  if [ -f "$prof" ]; then
    # Remove the exact SF2_LIVE_TTY1 block
    $SUDO sed -i '/^# --- SF2_LIVE_TTY1 ---$/,/^# --- SF2_LIVE_TTY1 ---$/d' "$prof" || true
    # Remove any legacy one-liners
    $SUDO sed -i '\|/usr/local/bin/sf2-live|d' "$prof" || true
  fi
}

# Try the invoking user, current uid, and root (deduped)
declare -A SEEN=()
for u in ${SUDO_USER:-}; do :; done   # no-op to avoid unbound
for u in "${SUDO_USER:-}" "$(id -un)" root; do
  [ -n "$u" ] || continue
  if [ -z "${SEEN[$u]:-}" ]; then
    SEEN[$u]=1
    clean_profile "$u"
  fi
done

say "──────────────────────────────────────────────"
say " Removed."
say "──────────────────────────────────────────────"
