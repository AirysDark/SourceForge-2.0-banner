#!/bin/bash
. /usr/lib/sf2/colors.sh
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}LAN IP:${C_RST} ${C_VAL}${ip:-N/A}${C_RST}"
