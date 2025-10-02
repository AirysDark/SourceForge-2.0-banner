sudo tee install-sf2-complete.sh >/dev/null <<'INSTALL'
#!/usr/bin/env bash
# SourceForge 2.0 Banner — Complete installer (blue+white-dash plugins)
# Safe when piped or run from disk.

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

sudo mkdir -p "$BIN" "$PLUG_DIR" "$SHARE" "$LIB"

###############################################################################
# 1) sf2-banner (plugin-driven; plugins handle colors/lines)
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

# Run executable plugins in order
shopt -s nullglob
for s in /usr/lib/sf2/banner.d/*.sh; do
  [ -x "$s" ] || continue
  "$s"
done
hr
BANNER
sudo chmod 0755 "$BIN/sf2-banner"

###############################################################################
# 2) sf2-config (self-elevate; toggle exec bit; auto-refresh banner on exit)
###############################################################################
sudo tee "$BIN/sf2-config" >/dev/null <<'CONF'
#!/usr/bin/env bash
set -euo pipefail

# Self-elevate if not root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo -E -- "$0" "$@"
fi

DIR="/usr/lib/sf2/banner.d"
[ -d "$DIR" ] || { echo "No plugin dir: $DIR"; exit 1; }

while :; do
  echo "Plugins in: $DIR"
  i=1
  declare -A MAP=()
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    if [ -x "$f" ]; then st="ENABLED"; else st="disabled"; fi
    printf " %2d) %-24s [%s]\n" "$i" "$base" "$st"
    MAP[$i]="$f"
    i=$((i+1))
  done < <(find "$DIR" -maxdepth 1 -type f -name '*.sh' -print0 | sort -z)

  echo
  read -r -p "Toggle which # (q=quit): " pick || true
  case "${pick:-q}" in
    q|Q|'') break ;;
    ''|*[!0-9]*) continue ;;
  esac

  target="${MAP[$pick]:-}"
  [ -n "${target}" ] || continue

  if [ -x "$target" ]; then
    chmod a-x "$target" && echo "Disabled $(basename "$target")"
  else
    chmod a+x "$target" && echo "Enabled  $(basename "$target")"
  fi
  echo
done

# Auto-refresh
command -v /usr/local/bin/sf2-banner >/dev/null 2>&1 && /usr/local/bin/sf2-banner || true
CONF
sudo chmod 0755 "$BIN/sf2-config"

###############################################################################
# 3) Optional: install software-full.sh if shipped with this installer
###############################################################################
if [ -f "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" ]; then
  sudo install -m0755 "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"
fi

###############################################################################
# 4) Shared colors (blue+white) with ANSI fallback
###############################################################################
sudo tee "$LIB/colors.sh" >/dev/null <<'COLORS'
#!/bin/bash
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'
  C_BLUE=$'\e[38;5;33m'
  C_WHITE=$'\e[97m'
else
  C_RST=$'\e[0m'
  C_BLUE=$'\e[34m'
  C_WHITE=$'\e[97m'
fi
COLORS
sudo chmod 0644 "$LIB/colors.sh"

###############################################################################
# 5) Plugins
#    - Info lines: prefixed with WHITE "-" then BLUE label
#    - Commands block: NO dashes, aligned list with a blue separator line
###############################################################################
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

# 70-commands.sh (NO dashes; aligned; blue separator above commands)
sudo tee "$PLUG_DIR/70-commands.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
# Blue separator
cols=$(tput cols 2>/dev/null || echo 78)
printf '%s%s%s\n' "${C_BLUE}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"

# Aligned commands, no dashes
printf " %-22s : %s\n" "sf2-config"           "Toggle banner plugins"
printf " %-22s : %s\n" "sf2-software"         "Service/DB/DDNS/HTTPS menu"
printf " %-22s : %s\n" "sf2-banner --update"  "Refresh banner + plugins"
printf " %-22s : %s\n" "htop"                 "Resource monitor"
printf " %-22s : %s\n" "cpu"                  "CPU info & stats"
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
INSTALL
sudo chmod +x install-sf2-complete.sh