#!/usr/bin/env bash
# generate-log.sh - generate a large synthetic log file for Fluent Bit tail testing.
# Usage: ./generate-log.sh [LINES]
# Default LINES=100000
set -euo pipefail
LINES=${1:-100000}
OUT_FILE="sample.log"
START_TS=$(date '+%Y-%m-%d %H:%M:%S')
echo "Generating $LINES lines into $OUT_FILE ..." >&2
# Fast line generation; adjust pattern as desired.
# Using printf in a while loop is slower; seq+sed is faster and memory-light.
seq 1 "$LINES" | sed "s#^#${START_TS} INFO synthetic line #" > "$OUT_FILE"
echo "Done. $(wc -l < "$OUT_FILE") lines written." >&2
