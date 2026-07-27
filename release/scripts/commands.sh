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
BRANCH="dev-v${MINOR}"

READY_FILE=$(mktemp)
PROBLEM_FILE=$(mktemp)
trap 'rm -f "$READY_FILE" "$PROBLEM_FILE"' EXIT

grep -v '<version>' "$FILE" | awk -v minor="$MINOR" -v ready="$READY_FILE" -v problem="$PROBLEM_FILE" '
BEGIN { torelease=0; qa=0; unrc=0 }
/^[a-z]/ { chart=$1; gsub(/:/, "", chart); torelease=0; qa=0; unrc=0 }
/^  [^ ]/ { version=$1; gsub(/:/, "", version) }
/ToRelease: true/ { torelease=1 }
/QA: true/ { qa=1 }
/UnRC: true/ { unrc=1 }
/Released:/ {
  if (torelease && qa && unrc) print "release update charts " minor " " chart " " version >> ready
  else if (torelease && (!qa || !unrc)) print "release update charts " minor " " chart " " version >> problem
}
'

while IFS= read -r cmd; do
  chart=$(echo "$cmd" | awk '{print $5}')
  version=$(echo "$cmd" | awk '{print $6}')
  if gh api "repos/rancher/charts/contents/charts/${chart}/${version}?ref=${BRANCH}" &>/dev/null 2>&1; then
    echo "$cmd"
  else
    echo "$cmd" >> "$PROBLEM_FILE"
  fi
done < "$READY_FILE"

echo ""
echo "---------------------"
echo "PROBLEM CHARTS"
cat "$PROBLEM_FILE"
