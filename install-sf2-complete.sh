#!/usr/bin/env bash
# SourceForge 2.0 Banner — Complete installer (blue+white-dash plugins)
# Safe when piped or run from disk; self-elevates where needed.

set -e -o pipefail
SELF="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$SELF")" 2>/dev/null && pwd || echo /tmp)"
set -u

# Paths
BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
PLUG_DIR="$LIB/banner.d"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

say(){ printf '%s\n' "$*"; }

say "──────────────────────────────────────────────"
say " Installing SourceForge 2.0 Banner (blue plugins)"
say "──────────────────────────────────────────────"

sudo mkdir -p "$BIN" "$PLUG_DIR" "$SHARE"

###############################################################################
# 1) Install sf2-banner (plugin-driven, no hardcoded info)
###############################################################################
sudo tee "$BIN/sf2-banner" >/dev/null <<'BANNER'
#!/usr/bin/env bash
set -euo pipefail

supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'; C_BOLD=$'\e[1m'
  C_HEAD_TX=$'\e[38;5;195m'   # header text
  C_ACC=$'\e[38;5;81m'        # datetime accent
  C_SEP=$'\e[38;5;24m'        # blue line
else
  C_RST=$'\e[0m'; C_BOLD=$'\e[1m'
  C_HEAD_TX=$'\e[96m'; C_ACC=$'\e[36m'; C_SEP=$'\e[34m'
fi

hr(){ cols=$(tput cols 2>/dev/null || echo 78); printf '%s%s%s\n' "${C_SEP}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"; }

dt="$(date '+%H:%M - %a %d/%m/%y')"
hr
printf " %sSourceForge 2.0 Banner%s : %s%s%s\n" "${C_HEAD_TX}${C_BOLD}" "${C_RST}" "${C_ACC}" "$dt" "${C_RST}"
hr

# Run executable plugins in order, print as-is (plugins handle colors + white dash)
shopt -s nullglob
for s in /usr/lib/sf2/banner.d/*.sh; do
  [ -x "$s" ] || continue
  "$s"
done
hr
BANNER
sudo chmod 0755 "$BIN/sf2-banner"

###############################################################################
# 2) Install sf2-config wrapper (self-elevate + auto reload banner)
###############################################################################
if [ -f "$BIN/sf2-config" ] && ! grep -q ".sf2-config-real" "$BIN/sf2-config" 2>/dev/null; then
  sudo mv "$BIN/sf2-config" "$BIN/.sf2-config-real"
fi
sudo tee "$BIN/sf2-config" >/dev/null <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail
if [ "${EUID:-$(id -u)}" -ne 0 ]; then exec sudo -E -- "$0" "$@"; fi
if [ -x /usr/local/bin/.sf2-config-real ]; then /usr/local/bin/.sf2-config-real "$@"; fi
command -v /usr/local/bin/sf2-banner >/dev/null 2>&1 && /usr/local/bin/sf2-banner >/dev/null 2>&1 || true
WRAP
sudo chmod 0755 "$BIN/sf2-config"

###############################################################################
# 3) If sf2-software exists, wrap to auto reload banner on exit
###############################################################################
if [ -x "$BIN/sf2-software" ] && ! grep -q ".sf2-software-real" "$BIN/sf2-software" 2>/dev/null; then
  sudo mv "$BIN/sf2-software" "$BIN/.sf2-software-real"
  sudo tee "$BIN/sf2-software" >/dev/null <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail
if [ "${EUID:-$(id -u)}" -ne 0 ]; then exec sudo -E -- "$0" "$@"; fi
/usr/local/bin/.sf2-software-real "$@"
command -v /usr/local/bin/sf2-banner >/dev/null 2>&1 && /usr/local/bin/sf2-banner >/dev/null 2>&1 || true
WRAP
  sudo chmod 0755 "$BIN/sf2-software"
fi

###############################################################################
# 4) Optional: install software-full.sh if provided alongside this installer
###############################################################################
if [ -f "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" ]; then
  sudo install -m0755 "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"
fi

###############################################################################
# 5) Install shared colors + blue + white-dash plugins
###############################################################################
# colors.sh
sudo tee "$LIB/colors.sh" >/dev/null <<'COLORS'
#!/bin/bash
C_RST=$'\e[0m'
C_BLUE=$'\e[38;5;33m'
C_WHITE=$'\e[97m'
COLORS
sudo chmod 0644 "$LIB/colors.sh"

# 10-hostname.sh
sudo tee "$PLUG_DIR/10-hostname.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Hostname:${C_RST} $(hostname)"
PLUG
sudo chmod 0755 "$PLUG_DIR/10-hostname.sh"

# 20-uptime.sh
sudo tee "$PLUG_DIR/20-uptime.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Uptime:${C_RST} $(uptime -p)"
PLUG
sudo chmod 0755 "$PLUG_DIR/20-uptime.sh"

# 30-ip.sh
sudo tee "$PLUG_DIR/30-ip.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}LAN IP:${C_RST} ${ip:-N/A}"
PLUG
sudo chmod 0755 "$PLUG_DIR/30-ip.sh"

# 40-load.sh
sudo tee "$PLUG_DIR/40-load.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Load:${C_RST} ${load}"
PLUG
sudo chmod 0755 "$PLUG_DIR/40-load.sh"

# 50-ram.sh
sudo tee "$PLUG_DIR/50-ram.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
read -r mem_total mem_used mem_perc <<<"$(free -m | awk '/Mem:/ {printf "%dMi %dMi %.0f%%", $2, $3, ($3/$2)*100}')"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}RAM:${C_RST} ${mem_used} / ${mem_total} (${mem_perc})"
PLUG
sudo chmod 0755 "$PLUG_DIR/50-ram.sh"

# 60-disk.sh
sudo tee "$PLUG_DIR/60-disk.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Disk:${C_RST} ${disk}"
PLUG
sudo chmod 0755 "$PLUG_DIR/60-disk.sh"

# 70-commands.sh (starts with a blue separator, then commands; no trailing separator)
sudo tee "$PLUG_DIR/70-commands.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
# local hr (blue)
cols=$(tput cols 2>/dev/null || echo 78)
printf '%s%s%s\n' "${C_BLUE}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}sf2-config${C_RST}             : Toggle banner plugins"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}sf2-software${C_RST}           : Service/DB/DDNS/HTTPS menu"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}sf2-banner --update${C_RST}    : Refresh banner + plugins"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}htop${C_RST}                   : Resource monitor"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}cpu${C_RST}                    : CPU info & stats"
PLUG
sudo chmod 0755 "$PLUG_DIR/70-commands.sh"

###############################################################################
# 6) MOTD + profile hooks
###############################################################################
sudo tee "$MOTD" >/dev/null <<'HOOK'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
HOOK
sudo chmod +x "$MOTD"

sudo tee "$PROFILE" >/dev/null <<'PROFILE'
#!/bin/sh
# show banner for interactive shells that don't use pam_motd
case "$-" in
  *i*) [ -x /usr/local/bin/sf2-banner ] && [ -z "${SSH_TTY:-}" ] && /usr/local/bin/sf2-banner ;;
esac
PROFILE
sudo chmod +x "$PROFILE"

###############################################################################
# 7) Test run
###############################################################################
/usr/local/bin/sf2-banner || true

say "──────────────────────────────────────────────"
say " Done."
say "──────────────────────────────────────────────"