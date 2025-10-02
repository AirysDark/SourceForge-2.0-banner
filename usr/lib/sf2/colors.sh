#!/bin/bash
# Centralized palette for SF2
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }
if supports_256; then
  C_RST=$'\e[0m'
  C_LABEL=$'\e[38;5;33m'   # bright blue (labels)
  C_VAL=$'\e[38;5;81m'     # light blue  (values)
  C_BUL=$'\e[38;5;33m'     # bright blue (dash bullet)
  C_SEP=$'\e[38;5;24m'     # dark blue   (separators)
else
  C_RST=$'\e[0m'
  C_LABEL=$'\e[34m'
  C_VAL=$'\e[36m'
  C_BUL=$'\e[34m'
  C_SEP=$'\e[34m'
fi
