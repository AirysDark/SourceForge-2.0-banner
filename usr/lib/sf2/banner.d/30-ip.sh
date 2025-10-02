#!/bin/bash
. /usr/lib/sf2/colors.sh
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}LAN IP:${C_RST} ${ip:-N/A}"
