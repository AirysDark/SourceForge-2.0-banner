#!/bin/bash
. /usr/lib/sf2/colors.sh
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
printf " %s-%s %sLAN IP:%s %s%s%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "${ip:-N/A}" "$C_RST"
