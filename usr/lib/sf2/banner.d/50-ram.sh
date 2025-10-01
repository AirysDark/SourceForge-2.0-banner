#!/usr/bin/env bash
set -euo pipefail
read -r total used perc <<<"$(free -m | awk '/Mem:/ {printf "%dMi %dMi %.0f%%", $2, $3, ($3/$2)*100}')"
echo "RAM: ${used} / ${total} (${perc})"
