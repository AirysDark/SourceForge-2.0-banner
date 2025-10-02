#!/bin/bash
. /usr/lib/sf2/colors.sh
printf " %s-%s %sHostname:%s %s%s%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$(hostname)" "$C_RST"
