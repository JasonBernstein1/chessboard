#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./add_collection.sh <file.pgn>"
  exit 1
fi

PGN_FILE="$1"

# Accept bare name (e.g. Fischer) or full path (pgn/Fischer.pgn)
if [ ! -f "$PGN_FILE" ]; then
  PGN_FILE="pgn/$1"
  [ "${PGN_FILE##*.}" != "pgn" ] && PGN_FILE="pgn/$1.pgn"
fi

if [ ! -f "$PGN_FILE" ]; then
  echo "Error: '$1' not found (tried root and pgn/)"
  exit 1
fi

python3 - "$PGN_FILE" <<'EOF'
import re, sys
pgn_file = sys.argv[1]
pgn = open(pgn_file, encoding='utf-8').read().replace('`', r'\`')
js = open('collections.js', encoding='utf-8').read().rstrip()
js = re.sub(r'\]\s*;?\s*$', '', js)
basename = pgn_file.split('/')[-1]
js += f',\n  {{ filename: "{basename}", pgn: `{pgn}` }}\n];\n'
open('collections.js', 'w', encoding='utf-8').write(js)
count = pgn.count('[Event ')
print(f"Added {count} games from {pgn_file}")
EOF
