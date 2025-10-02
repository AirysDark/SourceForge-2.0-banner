#!/bin/bash
. /usr/lib/sf2/colors.sh
cols=$(tput cols 2>/dev/null || echo 78)
printf "%s%s%s\n" "$C_SEP" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "$C_RST"
printf " %s-%s %ssf2-config:%s       %sToggle banner plugins%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$C_RST"
printf " %s-%s %ssf2-software:%s     %sService/DB/DDNS/HTTPS menu%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$C_RST"
printf " %s-%s %ssf2-banner --update:%s %sRefresh banner + plugins%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$C_RST"
printf " %s-%s %shtop:%s             %sResource monitor%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$C_RST"
printf " %s-%s %scpu:%s              %sCPU info & stats%s\n" "$C_BUL" "$C_RST" "$C_LABEL" "$C_RST" "$C_VAL" "$C_RST"
