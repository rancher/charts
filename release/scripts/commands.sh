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
/^[a-z]/ { chart=$1; gsub(/:/, "", chart) }
/^  [^ ]/ { version=$1; gsub(/:/, "", version) }
/ToRelease: true/ { print "release update charts " minor " " chart " " version }
'
