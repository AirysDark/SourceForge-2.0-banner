#!/bin/bash
. /usr/lib/sf2/colors.sh
disk=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
printf " %s-%s %sDisk:%s %s%s%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$disk" "$C_RST"
