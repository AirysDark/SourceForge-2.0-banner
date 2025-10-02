#!/bin/bash
. /usr/lib/sf2/colors.sh
read -r mem_total mem_used mem_perc <<<"$(free -m | awk '/Mem:/ {printf "%dMi %dMi %.0f%%", $2, $3, ($3/$2)*100}')"
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}RAM:${C_RST} ${mem_used} / ${mem_total} (${mem_perc})"
