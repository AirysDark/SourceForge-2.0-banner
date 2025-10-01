#!/bin/sh
awk '
  /MemTotal:/      { t=$2 }
  /MemAvailable:/  { a=$2 }
  END {
    if (t > 0) {
      u = t - a
      printf "- RAM: %.1fGiB / %.1fGiB (%.0f%%)\n", u/1048576, t/1048576, (u/t)*100
    } else {
      print "- RAM: N/A"
    }
  }
' /proc/meminfo
