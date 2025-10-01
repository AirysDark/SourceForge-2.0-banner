#!/bin/sh
# 70-commands.sh — show useful SF2 commands under the banner

print_cmd() {
  cmd="$1"; shift
  desc="$*"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf " [SF2] %-14s : %s\n" "$cmd" "$desc"
  fi
}

echo "[SF2] Commands:"
print_cmd sf2-config   "Toggle banner plugins"
print_cmd sf2-launcher "All SF2 tools in one place"
print_cmd sf2-software "Install optimized software"
print_cmd sf2-update   "Update system/packages"
print_cmd htop         "Resource monitor"
print_cmd cpu          "CPU info & stats"
