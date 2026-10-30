#!/usr/bin/env bash
# verify.sh — layout of the Omarchy theme repo (no containers). Prints PASS/FAIL; exits non-zero
# on failure. The umbrella's scripts/verify.sh runs this too.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

# layout: the files of a current Omarchy 4 theme repo (platform plan P10); colors.toml parses and
# has the core keys of the bundled themes (plan V14, ADR 0013); wallpapers are 16:9, >= 3840x2160.
if out=$(python3 -I - 2>&1 <<'PY'
import glob, os, struct, sys, tomllib
for f in ("colors.toml", "icons.theme", "preview.png", "README.md", "LICENSE"):
    if not os.path.isfile(f):
        sys.exit(f"missing {f}")
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
walls = sorted(glob.glob("backgrounds/*.png"))
if not walls:
    sys.exit("no wallpapers in backgrounds/")
for p in walls + ["preview.png"]:
    head = open(p, "rb").read(24)
    if head[:8] != b"\x89PNG\r\n\x1a\n" or head[12:16] != b"IHDR":
        sys.exit(f"{p} is not a PNG")
    w, h = struct.unpack(">II", head[16:24])
    if w * 9 != h * 16:
        sys.exit(f"{p} is {w}x{h}, not 16:9")
    if p in walls and w < 3840:
        sys.exit(f"{p} is {w}x{h}, smaller than 3840x2160")
PY
); then
  echo "PASS layout"
else
  echo "FAIL layout: $(tail -n 1 <<<"$out")"
  exit 1
fi
