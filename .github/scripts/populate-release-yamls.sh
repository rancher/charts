#!/usr/bin/env bash
set -euo pipefail

VERSIONS="$1"

IFS=',' read -ra VERSION_ARRAY <<< "${VERSIONS}"

for VERSION in "${VERSION_ARRAY[@]}"; do
  # Extract minor version (2.14.4 -> 2.14)
  MINOR=$(echo "${VERSION}" | cut -d. -f1-2)

  echo "Populating ${VERSION} (minor: ${MINOR})..." >&2

  # Run populate-release-charts CLI (fail-fast)
  if ! OUTPUT=$(npx tsx release/tracker/src/cli.ts populate-release-charts "${MINOR}" 2>&1); then
    echo "ERROR: Failed to populate ${VERSION}" >&2
    echo "${OUTPUT}" >&2
    exit 1
  fi

  echo "${OUTPUT}" >&2
done

echo "All versions populated successfully" >&2
