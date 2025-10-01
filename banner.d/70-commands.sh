#!/bin/sh
print_cmd() { cmd="$1"; shift; desc="$*"; if command -v $(echo "$cmd" | awk '{print $1}') >/dev/null 2>&1; then printf " [SF2] %-18s : %s\n" "$cmd" "$desc"; fi }
echo "[SF2] Commands:"; print_cmd sf2-config "Toggle banner plugins"; print_cmd sf2-launcher "All SF2 tools in one place"; print_cmd sf2-software "Install optimized software"; print_cmd sf2-update "Update system/packages"; print_cmd "sf2-banner --update" "Refresh banner + plugins"; print_cmd htop "Resource monitor"; print_cmd cpu "CPU info & stats"
