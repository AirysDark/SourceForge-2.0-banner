#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_LABEL}-${C_RST} ${C_LABEL}RAM:${C_RST} ${C_VAL}$(free -m | awk '/Mem:/ {printf "%dMi %dMi %.0f%%", $2, $3, ($3/$2)*100}')${C_RST}"
