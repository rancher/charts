#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <before-sha> <after-sha>"
  exit 1
fi

BEFORE="$1"
AFTER="$2"

FILES=$(git diff --name-only "$BEFORE" "$AFTER" -- 'release/*.yaml' | paste -sd, -)

if [[ -z "$FILES" ]]; then
  echo "[]"
  exit 0
fi

npx tsx release/tracker/src/cli.ts detect-qa-done "$BEFORE" "$FILES"
