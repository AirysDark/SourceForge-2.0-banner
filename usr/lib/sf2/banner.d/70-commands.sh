#!/bin/bash
. /usr/lib/sf2/colors.sh
# Blue separator above commands
cols=$(tput cols 2>/dev/null || echo 78)
printf '%s%s%s\n' "${C_SEP}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"
printf " %-22s : %s\n" "sf2-config"           "Toggle banner plugins"
printf " %-22s : %s\n" "sf2-software"         "Service/DB/DDNS/HTTPS menu"
printf " %-22s : %s\n" "sf2-banner --update"  "Refresh banner + plugins"
printf " %-22s : %s\n" "htop"                 "Resource monitor"
printf " %-22s : %s\n" "cpu"                  "CPU info & stats"
