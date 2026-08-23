#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(python3 - <<'PY' "$ROOT/metadata.json"
import json,sys
with open(sys.argv[1],encoding='utf-8') as f:
    print(json.load(f)['KPlugin']['Version'])
PY
)"
OUTDIR="$ROOT/dist"
OUT="$OUTDIR/Simple-Plasma-Agenda-${VERSION}.plasmoid"

mkdir -p "$OUTDIR"
rm -f "$OUT"

cd "$ROOT"
zip -qr "$OUT" metadata.json contents LICENSE NOTICE.md
printf 'Created: %s\n' "$OUT"
