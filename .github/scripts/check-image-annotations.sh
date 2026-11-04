#!/usr/bin/env bash
# Rejects chart versions added by a PR whose Chart.yaml lacks a valid
# helm.sh/images annotation (HIP-0015). Security scanning and air-gap
# tooling read a chart's images from that annotation instead of rendering
# templates.
#
# Only chart versions absent from the base branch are checked, so charts
# released before this check existed are left alone.
#
# Usage: check-image-annotations.sh <base_ref> <exempt_file>
set -euo pipefail

BASE_REF="$1"
EXEMPT_FILE="$2"
BASE="origin/${BASE_REF}"

if ! git rev-parse --verify --quiet "${BASE}" >/dev/null; then
  git fetch --depth=1 origin "+refs/heads/${BASE_REF}:refs/remotes/${BASE}"
fi

EXEMPT=$(yq '.exempt[]' "${EXEMPT_FILE}")

# Two-dot diff compares trees, so it needs no merge base in a shallow clone.
ADDED=$(git diff --name-only --diff-filter=A "${BASE}" HEAD -- ':(glob)charts/*/*/Chart.yaml')

if [[ -z "${ADDED}" ]]; then
  echo "No new chart versions in this PR"
  exit 0
fi

FAILED=0
while read -r CHART_YAML; do
  CHART=$(echo "${CHART_YAML}" | cut -d/ -f2)
  VERSION=$(echo "${CHART_YAML}" | cut -d/ -f3)

  if grep -qxF "${CHART}" <<<"${EXEMPT}"; then
    echo "SKIP: ${CHART} ${VERSION} (exempt, ships no images)"
    continue
  fi

  IMAGES=$(yq '.annotations["helm.sh/images"] // ""' "${CHART_YAML}")
  if [[ -z "${IMAGES}" ]]; then
    echo "FAIL: ${CHART} ${VERSION}: missing helm.sh/images annotation" >&2
    FAILED=1
    continue
  fi

  # The annotation is a string holding a YAML list of {name, image, os?}.
  if ! VALID=$(yq 'tag == "!!seq" and length > 0 and all_c(.image != null and .image != "")' <<<"${IMAGES}" 2>/dev/null) \
      || [[ "${VALID}" != "true" ]]; then
    echo "FAIL: ${CHART} ${VERSION}: helm.sh/images must be a non-empty YAML list whose entries each set 'image'" >&2
    FAILED=1
    continue
  fi

  echo "PASS: ${CHART} ${VERSION}"
done <<<"${ADDED}"

if [[ ${FAILED} -ne 0 ]]; then
  echo "" >&2
  echo "New chart versions must list the images they deploy in Chart.yaml, e.g.:" >&2
  echo "" >&2
  echo "  annotations:" >&2
  echo "    helm.sh/images: |" >&2
  echo "      - name: fleet-agent" >&2
  echo "        image: rancher/fleet-agent:v0.17.0" >&2
  echo "" >&2
  echo "See https://github.com/helm/community/blob/main/hips/hip-0015.md." >&2
  echo "Charts that deploy no images can be listed in config/image-annotations.yaml" >&2
  echo "on the automation-core branch." >&2
  exit 1
fi
