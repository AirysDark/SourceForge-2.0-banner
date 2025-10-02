#!/bin/bash
. /usr/lib/sf2/colors.sh
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Disk:${C_RST} ${disk}"
