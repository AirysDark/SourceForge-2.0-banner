#!/bin/bash
. /usr/lib/sf2/colors.sh
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Disk:${C_RST} ${C_VAL}${disk}${C_RST}"
