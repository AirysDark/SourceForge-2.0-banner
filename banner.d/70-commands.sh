#!/bin/sh
print_cmd() {
  cmd="$1"; shift
  desc="$*"
  bin=$(echo "$cmd" | awk '{print $1}')
  if command -v "$bin" >/dev/null 2>&1; then
    printf "%-20s : %s\n" "$cmd" "$desc"
  fi
}
print_cmd sf2-config            "Toggle banner plugins"
print_cmd sf2-software          "Service/DB/DDNS/HTTPS menu"
print_cmd "sf2-banner --update" "Refresh banner + plugins"
print_cmd htop                  "Resource monitor"
print_cmd cpu                   "CPU info & stats"
echo "────────────────────────────────────"
