#!/bin/bash
. /usr/lib/sf2/colors.sh
cols=$(tput cols 2>/dev/null || echo 78)
printf '%s%s%s\n' "${C_SEP}" "$(printf '%*s' "$cols" '' | tr ' ' '-')" "${C_RST}"
# NO dashes; aligned; labels left dark blue, desc light blue
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-config"           "${C_RST}" "${C_VAL}" "Toggle banner plugins"        "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-software"         "${C_RST}" "${C_VAL}" "Service/DB/DDNS/HTTPS menu"   "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "sf2-banner --update"  "${C_RST}" "${C_VAL}" "Refresh banner + plugins"     "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "htop"                 "${C_RST}" "${C_VAL}" "Resource monitor"              "${C_RST}"
printf " %s%-22s%s : %s%s%s\n" "${C_LABEL}" "cpu"                  "${C_RST}" "${C_VAL}" "CPU info & stats"              "${C_RST}"
