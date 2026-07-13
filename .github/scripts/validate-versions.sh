#!/usr/bin/env bash
set -euo pipefail

VERSIONS="$1"
VERSIONS="${VERSIONS// /}"

# Validate format (X.Y.Z,X.Y.Z,...)
if [[ ! "${VERSIONS}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(,[0-9]+\.[0-9]+\.[0-9]+)*$ ]]; then
  echo "ERROR: Invalid version format: ${VERSIONS}" >&2
  echo "Expected: X.Y.Z,X.Y.Z (e.g., 2.14.4,2.13.8)" >&2
  exit 1
fi

VERSION_COUNT=$(echo "${VERSIONS}" | tr ',' '\n' | wc -l)

# Output to stdout
echo "versions=${VERSIONS}"
echo "count=${VERSION_COUNT}"
