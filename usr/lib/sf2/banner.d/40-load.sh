#!/bin/bash
. /usr/lib/sf2/colors.sh
echo -e " ${C_LABEL}-${C_RST} ${C_LABEL}Load:${C_RST} ${C_VAL}$(awk '{print $1, $2, $3}' /proc/loadavg)${C_RST}"
