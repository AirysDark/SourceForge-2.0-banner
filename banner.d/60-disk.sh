#!/bin/sh
df -h / | awk 'NR==2{print "Disk: "$3" / "$2" ("$5")"}'\n