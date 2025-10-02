#!/bin/bash
. /usr/lib/sf2/colors.sh
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
echo -e " ${C_WHITE}-${C_RST} ${C_BLUE}Load:${C_RST} ${load}"
