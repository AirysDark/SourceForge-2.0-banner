#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_LABEL}-${C_RST} ${C_LABEL}Disk:${C_RST} ${C_VAL}$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')${C_RST}"
