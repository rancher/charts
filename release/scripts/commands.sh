#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <release-file> (e.g. release/2.15.0.yaml)"
  exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: file not found: $FILE"
  exit 1
fi

# Extract minor version from filename: 2.15.0.yaml -> 2.15
MINOR=$(basename "$FILE" .yaml | grep -oE '^[0-9]+\.[0-9]+')

grep -v '<version>' "$FILE" | awk -v minor="$MINOR" '
BEGIN { ri=0; di=0 }
/^[a-z]/ { chart=$1; gsub(/:/, "", chart); torelease=0; qa=0; unrc=0 }
/^  [^ ]/ { version=$1; gsub(/:/, "", version) }
/ToRelease: true/ { torelease=1 }
/QA: true/ { qa=1 }
/UnRC: true/ { unrc=1 }
/Released:/ {
  if (torelease && qa && unrc) { ready[ri++] = "release update charts " minor " " chart " " version }
  else if (torelease && (!qa || !unrc)) { delayed[di++] = "release update charts " minor " " chart " " version }
}
END {
  for (i=0; i<ri; i++) print ready[i]
  print ""
  print "---------------------"
  print "DELAYED CHARTS"
  for (i=0; i<di; i++) print delayed[i]
}
'
