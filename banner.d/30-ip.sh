#!/bin/sh
ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo "- LAN IP: ${ip:-N/A}"\n