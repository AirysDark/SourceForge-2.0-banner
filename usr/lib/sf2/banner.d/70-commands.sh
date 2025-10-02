#!/bin/bash
# Commands list for SF2 banner

. /usr/lib/sf2/colors.sh

echo
printf "%s%-22s%s : %s%s%s\n" "$C_LABEL" "sf2-config"          "$C_RST" "$C_ACC" "Toggle banner plugins"        "$C_RST"
printf "%s%-22s%s : %s%s%s\n" "$C_LABEL" "sf2-software"        "$C_RST" "$C_ACC" "Service/DB/DDNS/HTTPS menu"   "$C_RST"
printf "%s%-22s%s : %s%s%s\n" "$C_LABEL" "sf2-banner --update" "$C_RST" "$C_ACC" "Refresh banner + plugins"     "$C_RST"
printf "%s%-22s%s : %s%s%s\n" "$C_LABEL" "htop"                "$C_RST" "$C_ACC" "Resource monitor"              "$C_RST"
printf "%s%-22s%s : %s%s%s\n" "$C_LABEL" "cpu"                 "$C_RST" "$C_ACC" "CPU info & stats"              "$C_RST"