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
VERSIONED_OUT="$OUTDIR/Simple-Plasma-Agenda-${VERSION}.plasmoid"
STABLE_OUT="$OUTDIR/Simple-Plasma-Agenda.plasmoid"

mkdir -p "$OUTDIR"
rm -f "$VERSIONED_OUT" "$STABLE_OUT"

cd "$ROOT"
zip -qr "$VERSIONED_OUT" metadata.json contents LICENSE NOTICE.md
cp -f "$VERSIONED_OUT" "$STABLE_OUT"

printf 'Created: %s\n' "$VERSIONED_OUT"
printf 'Created: %s\n' "$STABLE_OUT"
