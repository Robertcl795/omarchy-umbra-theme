#!/usr/bin/env bash
# verify.sh — layout of the Omarchy theme repo (no containers). Prints PASS/FAIL; exits non-zero
# on failure. The umbrella's scripts/verify.sh runs this too.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

# layout: colors.toml parses and has the core keys of the bundled themes (plan V14, ADR 0013).
if out=$(python3 -I - 2>&1 <<'PY'
import sys, tomllib
colors = tomllib.load(open("colors.toml", "rb"))
core = {"mode", "accent", "selection", "muted", "background", "dark_background", "darker_background",
        "lighter_background", "foreground", "dark_foreground", "light_foreground", "bright_foreground",
        "red", "yellow", "green", "cyan", "blue", "magenta", "bright_red", "bright_yellow",
        "bright_green", "bright_cyan", "bright_blue", "bright_magenta"}
missing = core - set(colors)
if missing:
    sys.exit("colors.toml lacks: " + " ".join(sorted(missing)))
if not open("icons.theme").read().strip():
    sys.exit("icons.theme is empty")
PY
); then
  echo "PASS layout"
else
  echo "FAIL layout: $(tail -n 1 <<<"$out")"
  exit 1
fi
