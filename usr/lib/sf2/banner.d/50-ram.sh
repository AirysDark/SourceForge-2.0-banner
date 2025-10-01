#!/bin/sh
free -h | awk 'NR==2{print "RAM: "$3" / "$2}'"
