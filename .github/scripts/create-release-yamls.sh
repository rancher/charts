#!/usr/bin/env bash
set -euo pipefail

FILENAMES="$1"

IFS=',' read -ra FILENAME_ARRAY <<< "${FILENAMES}"

for FILENAME in "${FILENAME_ARRAY[@]}"; do
  TARGET="release/${FILENAME}"

  echo "Creating ${TARGET}..." >&2

  if ! cp templates/release-versions.yaml "${TARGET}"; then
    echo "ERROR: Failed to copy template to ${TARGET}" >&2
    exit 1
  fi

done

echo "Successfully created ${#FILENAME_ARRAY[@]} release tracking file(s)" >&2
