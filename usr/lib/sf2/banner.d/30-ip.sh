#!/bin/sh
echo "LAN IP: $(hostname -I | awk '{print $1}')"
