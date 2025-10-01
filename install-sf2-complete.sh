#!/usr/bin/env bash
set -euo pipefail
echo "Installing SourceForge 2.0 Banner..."
install -Dm755 sf2-banner /usr/local/bin/sf2-banner
install -Dm755 bin/sf2-config /usr/local/bin/sf2-config
install -Dm755 bin/cpu /usr/local/bin/cpu
install -Dm755 bin/sf2-software /usr/local/bin/sf2-software
install -Dm755 usr/local/share/sf2/software-full.sh /usr/local/share/sf2/software-full.sh
echo "Done."
