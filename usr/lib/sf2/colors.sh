#!/bin/bash
# Colors for SF2 banner
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'
  C_LABEL=$'\e[38;5;33m'    # bright blue (dash + labels)
  C_VAL=$'\e[38;5;81m'      # light blue values
  C_BUL=$C_LABEL
  C_SEP=$C_LABEL
else
  C_RST=$'\e[0m'
  C_LABEL=$'\e[34m'
  C_VAL=$'\e[36m'
  C_BUL=$C_LABEL
  C_SEP=$C_LABEL
fi
