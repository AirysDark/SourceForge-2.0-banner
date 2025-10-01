#!/bin/sh
# 50-ram.sh — show RAM usage

if free -b >/dev/null 2>&1; then
  free -b | awk 'NR==2 {printf "[SF2] RAM: %.1fGiB / %.1fGiB (%.0f%%)\n", $3/1024/1024/1024, $2/1024/1024/1024, ($3/$2)*100}'
else
  free -h | awk 'NR==2 {print "[SF2] RAM: "$3" / "$2}'
fi
