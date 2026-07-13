#!/usr/bin/env bash
set -euo pipefail

VERSIONS="$1"

# Verify directory structure
if [[ ! -d "release/tracker" ]]; then
  echo "ERROR: release/tracker/ directory not found" >&2
  exit 1
fi

if [[ ! -f "templates/release-versions.yaml" ]]; then
  echo "ERROR: templates/release-versions.yaml template not found" >&2
  exit 1
fi

# Check for existing release YAML files
IFS=',' read -ra VERSION_ARRAY <<< "${VERSIONS}"
EXISTING=()

for VERSION in "${VERSION_ARRAY[@]}"; do
  if [[ -f "release/${VERSION}.yaml" ]]; then
    EXISTING+=("release/${VERSION}.yaml")
  fi
done

if [[ ${#EXISTING[@]} -gt 0 ]]; then
  echo "ERROR: Cannot create - files already exist:" >&2
  for FILE in "${EXISTING[@]}"; do
    echo "  ${FILE}" >&2
  done
  exit 1
fi

# All clear - output versions to create
echo "versions_to_create=${VERSIONS}"
