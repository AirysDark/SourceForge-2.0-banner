#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_LABEL}-${C_RST} ${C_LABEL}LAN IP:${C_RST} ${C_VAL}$(hostname -I 2>/dev/null | awk '{print $1}')${C_RST}"
