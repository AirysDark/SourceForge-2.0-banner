#!/bin/bash
. /usr/lib/sf2/colors.sh
load=$(awk '{print $1, $2, $3}' /proc/loadavg)
printf " %s-%s %sLoad:%s %s%s%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$load" "$C_RST"
