#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIAGRAM_DIR="${1:-$ROOT_DIR/diagrams}"

if [[ ! -d "$DIAGRAM_DIR" ]]; then
  echo "Error: diagram directory not found: $DIAGRAM_DIR" >&2
  exit 1
fi

DRAWIO_BIN="${DRAWIO_BIN:-}"
if [[ -z "$DRAWIO_BIN" ]]; then
  for c in "/c/apps/drawio/draw.io" "drawio" "draw.io" "diagrams.net"; do
    if command -v "$c" >/dev/null 2>&1; then
      DRAWIO_BIN="$(command -v "$c")"
      break
    elif [[ -x "$c" ]]; then
      DRAWIO_BIN="$c"
      break
    fi
  done
fi

if [[ -z "$DRAWIO_BIN" ]]; then
  echo "Error: draw.io CLI not found. Set DRAWIO_BIN=/path/to/draw.io" >&2
  exit 1
fi

echo "Using draw.io CLI: $DRAWIO_BIN"
echo "Exporting .drawio -> .svg under: $DIAGRAM_DIR"

count=0
while IFS= read -r -d '' f; do
  out="${f%.drawio}.svg"
  "$DRAWIO_BIN" -x -f svg -o "$out" "$f"
  count=$((count + 1))
done < <(find "$DIAGRAM_DIR" -maxdepth 1 -type f -name '*.drawio' -print0 | sort -z)

echo "Done. Exported $count files."
