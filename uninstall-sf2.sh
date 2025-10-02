#!/usr/bin/env bash
# SourceForge 2.0 Banner — Uninstaller (incl. tty1 autologin & live dashboard cleanup)
set -euo pipefail

say(){ printf '%s\n' "$*"; }

say "──────────────────────────────────────────────"
say " Uninstalling SourceForge 2.0 Banner"
say "──────────────────────────────────────────────"

# ---------- Stop any live dashboard ----------
# Best-effort: kill watch running sf2-banner
pkill -f "watch -t -n .* sf2-banner" 2>/dev/null || true

# ---------- Remove wrappers/real binaries ----------
sudo rm -f /usr/local/bin/.sf2-config-real /usr/local/bin/.sf2-software-real || true

# ---------- Remove public commands ----------
sudo rm -f /usr/local/bin/sf2-banner
sudo rm -f /usr/local/bin/sf2-config
sudo rm -f /usr/local/bin/sf2-software
sudo rm -f /usr/local/bin/sf2-live
sudo rm -f /usr/local/bin/cpu

# ---------- Remove shared menu file if installed ----------
sudo rm -f /usr/local/share/sf2/software-full.sh

# ---------- Remove MOTD and profile hooks ----------
sudo rm -f /etc/update-motd.d/00-sf2-banner
sudo rm -f /etc/profile.d/00-sf2-banner.sh

# ---------- Remove plugins + colors ----------
sudo rm -rf /usr/lib/sf2

# ---------- Revert tty1 autologin override (if present) ----------
OVR_DIR="/etc/systemd/system/getty@tty1.service.d"
OVR_FILE="$OVR_DIR/override.conf"
if [ -f "$OVR_FILE" ]; then
  sudo rm -f "$OVR_FILE"
  # remove dir if empty
  rmdir "$OVR_DIR" 2>/dev/null || true
  sudo systemctl daemon-reload
  sudo systemctl restart getty@tty1.service || true
  say "Reverted tty1 autologin override."
fi

# ---------- Remove live dashboard autostart from bash_profile ----------
# Target the invoking user (or fallback), and also root just in case
CAND_USERS=()

if [ "${SUDO_USER:-}" ]; then CAND_USERS+=("$SUDO_USER"); fi
CAND_USERS+=("$(id -un)")
CAND_USERS+=("root")

clean_profile() {
  local user="$1"
  local home
  home="$(getent passwd "$user" | cut -d: -f6)"
  [ -n "${home:-}" ] || home="/home/$user"
  local prof="$home/.bash_profile"
  if [ -f "$prof" ]; then
    # Remove the exact SF2_LIVE_TTY1 snippet block if present
    sudo sed -i '/^# --- SF2_LIVE_TTY1 ---$/,/^# --- SF2_LIVE_TTY1 ---$/d' "$prof" || true
    # Fallback: remove legacy one-liner if any
    sudo sed -i '\|/usr/local/bin/sf2-live|d' "$prof" || true
  fi
}

# Deduplicate users and clean
DEDUP=""
for u in "${CAND_USERS[@]}"; do
  case " $DEDUP " in *" $u "*) : ;; *) DEDUP="$DEDUP $u"; clean_profile "$u";; esac
done

say "──────────────────────────────────────────────"
say " Removed."
say "──────────────────────────────────────────────"