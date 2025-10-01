#!/bin/sh
df -h / | awk 'NR==2{print "[SF2] Disk: "$3" / "$2" ("$5")"}'
