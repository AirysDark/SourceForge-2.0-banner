#!/bin/sh
free -h | awk 'NR==2{print "[SF2] RAM: "$3" / "$2}'"
