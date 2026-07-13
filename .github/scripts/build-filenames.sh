#!/usr/bin/env bash
set -euo pipefail

VERSIONS="$1"

IFS=',' read -ra VERSION_ARRAY <<< "${VERSIONS}"
FILENAMES=()

for VERSION in "${VERSION_ARRAY[@]}"; do
  FILENAMES+=("${VERSION}.yaml")
done

echo "filenames=$(IFS=,; echo "${FILENAMES[*]}")"
