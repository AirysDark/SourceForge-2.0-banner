#!/bin/sh
# 50-ram.sh — show RAM usage (robust quoting)

if free -b >/dev/null 2>&1; then
  free -b | awk 'NR==2 {printf "[SF2] RAM: %.1fGiB / %.1fGiB (%.0f%%)\n", $3/1073741824, $2/1073741824, ($3/$2)*100}'
else
  free -h | awk 'NR==2 {printf "[SF2] RAM: %s / %s\n", $3, $2}'
fi
