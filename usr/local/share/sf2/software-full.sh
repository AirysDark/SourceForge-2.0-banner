#!/usr/bin/env bash
set -euo pipefail

# Dark blue menu from earlier (full embedded script)
# This is the Gitea/Runner/MySQL/DDNS/HTTPS full menu

# Colors
C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'
C_PRIM_BG=$'\e[48;5;17m'; C_PRIM_TX=$'\e[38;5;153m'; C_HEAD_TX=$'\e[38;5;195m'
C_ACC=$'\e[38;5;81m'; C_MUTED=$'\e[38;5;244m'; C_OK=$'\e[38;5;120m'
C_WARN=$'\e[38;5;214m'; C_ERR=$'\e[38;5;203m'; C_LINK=$'\e[38;5;110m'; C_BOX=$'\e[38;5;24m'

term_width(){ tput cols 2>/dev/null || echo 80; }
hr(){ local w; w=$(term_width); printf '%s\n' "$(printf '%*s' "$w" '' | tr ' ' '─')"; }
pad_center(){ local t="$1" w; w=$(term_width); local l=${#t}; local p=$(( (w-l)/2 )); ((p<0))&&p=0; printf '%*s%s%*s\n' "$p" '' "$t" "$p" ''; }

banner(){ local t="$1" s="${2-}"; local w; w=$(term_width)
  printf "${C_PRIM_BG}${C_HEAD_TX}${C_BOLD}%s\n" "$(printf '%*s' "$w" ' ' )"
  pad_center "⚙ SourceForge 2.0 Software Manager"
  pad_center "$t"
  [[ -n "$s" ]] && pad_center "${C_PRIM_TX}${s}${C_HEAD_TX}"
  printf "%s${C_RESET}\n" "$(printf '%*s' "$w" ' ' )"
}

main_menu(){
  while true; do
    clear; banner "Main Menu" "Dark Blue UI • bash only • zero deps"
    echo "${C_BOX}┌──────────────────────────────────────────────┐${C_RESET}"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}1)${C_RESET} Install Gitea server & configs"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}2)${C_RESET} Install runner"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}3)${C_RESET} Runner hook to Gitea"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}4)${C_RESET} MySQL/MariaDB setup"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}5)${C_RESET} DNS (No-IP via ddclient)"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}6)${C_RESET} HTTPS reverse proxy (Nginx + Let's Encrypt)"
    echo "${C_BOX}│${C_RESET} ${C_BOLD}${C_ACC}q)${C_RESET} Quit"
    echo "${C_BOX}└──────────────────────────────────────────────┘${C_RESET}"
    read -rp "> " choice
    case "$choice" in
      q|Q) exit 0 ;;
      *) echo "Not yet implemented. Press Enter..."; read ;;
    esac
  done
}

main_menu
