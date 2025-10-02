#!/usr/bin/env bash
# SourceForge 2.0 Banner — Complete installer
# Blue labels + blue dashes (bright blue), light-blue values, dark-blue lines
# Works locally or clones GitHub if local files are missing.

set -e -o pipefail
SELF="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$SELF")" 2>/dev/null && pwd || echo /tmp)"
set -u

# ----- Repo to clone if local files aren't present -----
REPO_URL="${REPO_URL:-https://github.com/AirysDark/SourceForge-2.0-banner.git}"
TMP_SRC="/tmp/sf2-src"

# ----- Install paths -----
BIN="/usr/local/bin"
LIB="/usr/lib/sf2"
PLUG_DIR="$LIB/banner.d"
SHARE="/usr/local/share/sf2"
MOTD="/etc/update-motd.d/00-sf2-banner"
PROFILE="/etc/profile.d/00-sf2-banner.sh"

say(){ printf '%s\n' "$*"; }

say "──────────────────────────────────────────────"
say " Installing SourceForge 2.0 Banner (GitHub-aware)"
say "──────────────────────────────────────────────"

# Decide source: local or GitHub clone
need_any=0
for f in sf2-banner sf2-config usr/local/share/sf2/software-full.sh; do
  [ -e "$SCRIPT_DIR/$f" ] || need_any=1
done
if [ "$need_any" -eq 1 ]; then
  if ! command -v git >/dev/null 2>&1; then
    sudo apt-get update -y >/dev/null 2>&1 || true
    sudo apt-get install -y git >/dev/null 2>&1
  fi
  rm -rf "$TMP_SRC"
  if ! git clone --depth 1 "$REPO_URL" "$TMP_SRC"; then
    echo "[SF2] ERROR: Could not clone $REPO_URL"
    exit 1
  fi
  SCRIPT_DIR="$TMP_SRC"
fi

sudo mkdir -p "$BIN" "$PLUG_DIR" "$SHARE" "$LIB"

###############################################################################
# 1) sf2-banner (plugin runner; plugins print lines themselves)
###############################################################################
sudo tee "$BIN/sf2-banner" >/dev/null <<'BANNER'
#!/usr/bin/env bash
set -euo pipefail
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'; C_BOLD=$'\e[1m'
  C_HEAD_TX=$'\e[38;5;195m'   # title
  C_ACC=$'\e[38;5;81m'        # datetime (light blue)
  C_SEP=$'\e[38;5;24m'        # horizontal lines (dark blue)
else
  C_RST=$'\e[0m'; C_BOLD=$'\e[1m'
  C_HEAD_TX=$'\e[96m'; C_ACC=$'\e[36m'; C_SEP=$'\e[34m'
fi
hr(){ cols=$(tput cols 2>/dev/null || echo 78); printf '%s%s%s\n' "${C_SEP}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"; }
dt="$(date '+%H:%M - %a %d/%m/%y')"
hr
printf " %sSourceForge 2.0 Banner%s : %s%s%s\n" "${C_HEAD_TX}${C_BOLD}" "${C_RST}" "${C_ACC}" "$dt" "${C_RST}"
hr
shopt -s nullglob
for s in /usr/lib/sf2/banner.d/*.sh; do
  [ -x "$s" ] || continue
  "$s"
done
hr
BANNER
sudo chmod 0755 "$BIN/sf2-banner"
sudo chown root:root "$BIN/sf2-banner"

###############################################################################
# 2) sf2-config (root toggle; refresh banner on exit)
###############################################################################
sudo tee "$BIN/sf2-config" >/dev/null <<'CONF'
#!/usr/bin/env bash
set -euo pipefail
# Self-elevate
if [ "${EUID:-$(id -u)}" -ne 0 ]; then exec sudo -E -- "$0" "$@"; fi

DIR="/usr/lib/sf2/banner.d"
[ -d "$DIR" ] || { echo "No plugin dir: $DIR"; exit 1; }

while :; do
  echo "Plugins in: $DIR"
  i=1; declare -A MAP=()
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"; st=$([ -x "$f" ] && echo "ENABLED" || echo "disabled")
    printf " %2d) %-24s [%s]\n" "$i" "$base" "$st"
    MAP[$i]="$f"; i=$((i+1))
  done < <(find "$DIR" -maxdepth 1 -type f -name '*.sh' -print0 | sort -z)
  echo
  read -r -p "Toggle which # (q=quit): " pick || true
  case "${pick:-q}" in q|Q|'') break ;; ''|*[!0-9]*) continue ;; esac
  target="${MAP[$pick]:-}"; [ -n "$target" ] || continue
  if [ -x "$target" ]; then chmod a-x "$target" && echo "Disabled $(basename "$target")"
  else chmod a+x "$target" && echo "Enabled  $(basename "$target")"; fi
  echo
done

command -v /usr/local/bin/sf2-banner >/dev/null 2>&1 && /usr/local/bin/sf2-banner || true
CONF
sudo chmod 0755 "$BIN/sf2-config"
sudo chown root:root "$BIN/sf2-config"

###############################################################################
# 3) Optional software-full.sh (if repo provides it)
###############################################################################
if [ -f "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" ]; then
  sudo install -m0755 "$SCRIPT_DIR/usr/local/share/sf2/software-full.sh" "$SHARE/software-full.sh"
fi

###############################################################################
# 4) colors.sh
# Dash + label = bright blue (33); values = light blue (81); separators = dark blue (24)
###############################################################################
sudo tee "$LIB/colors.sh" >/dev/null <<'COLORS'
#!/bin/bash
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'
  C_LABEL=$'\e[38;5;33m'    # bright blue (labels)
  C_VAL=$'\e[38;5;81m'      # light blue (values)
  C_BUL=$'\e[38;5;33m'      # bright blue dash (matches label)
  C_SEP=$'\e[38;5;24m'      # dark blue line
else
  C_RST=$'\e[0m'
  C_LABEL=$'\e[34m'
  C_VAL=$'\e[36m'
  C_BUL=$'\e[34m'
  C_SEP=$'\e[34m'
fi
COLORS
sudo chmod 0644 "$LIB/colors.sh"
sudo chown root:root "$LIB/colors.sh"

###############################################################################
# 5) Plugins (dash + label = bright blue; value = light blue; commands have NO dash)
###############################################################################
sudo tee "$PLUG_DIR/10-hostname.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Hostname:${C_RST} ${C_VAL}$(hostname)${C_RST}"
PLUG

sudo tee "$PLUG_DIR/20-uptime.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Uptime:${C_RST} ${C_VAL}$(uptime -p)${C_RST}"
PLUG

sudo tee "$PLUG_DIR/30-ip.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}LAN IP:${C_RST} ${C_VAL}${ip:-N/A}${C_RST}"
PLUG

sudo tee "$PLUG_DIR/40-load.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Load:${C_RST} ${C_VAL}${load}${C_RST}"
PLUG

sudo tee "$PLUG_DIR/50-ram.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
read -r mem_total mem_used mem_perc <<<"$(free -m | awk '/Mem:/ {printf "%dMi %dMi %.0f%%", $2, $3, ($3/$2)*100}')"
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}RAM:${C_RST} ${C_VAL}${mem_used} / ${mem_total} (${mem_perc})${C_RST}"
PLUG

sudo tee "$PLUG_DIR/60-disk.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Disk:${C_RST} ${C_VAL}${disk}${C_RST}"
PLUG

sudo tee "$PLUG_DIR/70-commands.sh" >/dev/null <<'PLUG'
#!/bin/bash
. /usr/lib/sf2/colors.sh
# Dark blue separator above commands
cols=$(tput cols 2>/dev/null || echo 78)
printf '%s%s%s\n' "${C_SEP}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"

# NO dashes; aligned; command name (bright blue), description (light blue)
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-config"           "${C_RST}" "${C_VAL}" "Toggle banner plugins"        "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-software"         "${C_RST}" "${C_VAL}" "Service/DB/DDNS/HTTPS menu"   "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-banner --update"  "${C_RST}" "${C_VAL}" "Refresh banner + plugins"     "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "htop"                 "${C_RST}" "${C_VAL}" "Resource monitor"              "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "cpu"                  "${C_RST}" "${C_VAL}" "CPU info & stats"              "${C_RST}"
PLUG

sudo chmod 0755 "$PLUG_DIR"/*.sh
sudo chown -R root:root "$LIB"

###############################################################################
# 6) MOTD + profile hooks
###############################################################################
sudo tee "$MOTD" >/dev/null <<'HOOK'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
HOOK
sudo chmod +x "$MOTD"
sudo chown root:root "$MOTD"

sudo tee "$PROFILE" >/dev/null <<'PROFILE'
#!/bin/sh
# show banner for interactive shells that don't use pam_motd
case "$-" in
  *i*) [ -x /usr/local/bin/sf2-banner ] && [ -z "${SSH_TTY:-}" ] && /usr/local/bin/sf2-banner ;;
esac
PROFILE
sudo chmod +x "$PROFILE"
sudo chown root:root "$PROFILE"

###############################################################################
# 7) Test run
###############################################################################
/usr/local/bin/sf2-banner || true

say "──────────────────────────────────────────────"
say " Done."
say "──────────────────────────────────────────────"