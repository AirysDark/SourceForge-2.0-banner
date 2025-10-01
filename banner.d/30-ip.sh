#!/bin/sh
ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo "[SF2] LAN IP: ${ip:-N/A}"
