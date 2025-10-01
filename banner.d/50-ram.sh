sudo tee /usr/lib/sf2/banner.d/50-ram.sh >/dev/null <<'EOF'
#!/bin/sh
# 50-ram.sh — robust: parse /proc/meminfo (no free/awk quoting issues)

awk '
  /MemTotal:/      { t=$2 }        # kB
  /MemAvailable:/  { a=$2 }        # kB
  END {
    if (t > 0) {
      u = t - a                      # used kB
      printf "[SF2] RAM: %.1fGiB / %.1fGiB (%.0f%%)\n", u/1048576, t/1048576, (u/t)*100
    } else {
      print "[SF2] RAM: N/A"
    }
  }
' /proc/meminfo
EOF
sudo chmod +x /usr/lib/sf2/banner.d/50-ram.sh

# test it
sf2-banner