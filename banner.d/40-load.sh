#!/bin/bash
. /usr/lib/sf2/colors.sh
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
echo -e " ${C_BUL}-${C_RST} ${C_LABEL}Load:${C_RST} ${C_VAL}${load}${C_RST}"
