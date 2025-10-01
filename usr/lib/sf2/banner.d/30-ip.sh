#!/bin/sh
echo "[SF2] LAN IP: $(hostname -I | awk '{print $1}')"
