#!/bin/bash
# SF2 Banner Color Palette

supports_256(){ tput colors 2>/dev/null | awk '{exit !($1>=256)}'; }

if supports_256; then
  C_RST=$'\e[0m'
  C_LABEL=$'\e[38;5;24m'    # dark blue (labels + dash)
  C_VAL=$'\e[38;5;81m'      # light blue (values)
  C_BUL=$'\e[38;5;24m'      # dark blue bullet/dash
  C_SEP=$'\e[38;5;24m'      # dark blue separators
else
  C_RST=$'\e[0m'
  C_LABEL=$'\e[34m'         # blue fallback
  C_VAL=$'\e[36m'           # cyan fallback
  C_BUL=$'\e[34m'           # blue dash fallback
  C_SEP=$'\e[34m'           # blue line fallback
fi