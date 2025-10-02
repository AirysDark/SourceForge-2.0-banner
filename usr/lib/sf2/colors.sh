#!/bin/bash
# Auto-detect terminal color capability; fallback to basic ANSI if needed
supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }

if supports_256; then
  # 256-color palette
  C_RST=$'\e[0m'
  C_BUL=$'\e[97m'          # white dash
  C_LABEL=$'\e[38;5;81m'   # light blue/cyan label
  C_VAL=$'\e[97m'          # white value
  C_SEP=$'\e[38;5;24m'     # deep blue line
else
  # Basic ANSI fallback
  C_RST=$'\e[0m'
  C_BUL=$'\e[37m'          # white/grey dash
  C_LABEL=$'\e[36m'        # cyan label
  C_VAL=$'\e[97m'          # bright white value (or use \e[37m if too bright)
  C_SEP=$'\e[34m'          # blue line
fi