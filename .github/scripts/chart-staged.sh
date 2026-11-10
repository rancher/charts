#!/usr/bin/env bash
# Ships a chart that was pushed to the staging registry to this checkout, and
# indexes it: runs `cargueiro ship` and then `cargueiro index` on the current
# directory, which must be an up to date checkout of the staging branch.
#
# It writes the entry and the logo of the chart (ship), then the archive and the
# index (index). It does not commit or push: the workflow does, so the checks
# here can be run by hand.
#
# Environment:
#   CHART       the name of the chart that was pushed
#   VERSION     its chart version, as in its Chart.yaml (with the +)
#   REGISTRY    where the chart was pushed, host/path, with no chart name
#   PLAIN_HTTP  set to "true" to talk HTTP to the registry, for a local one
#   REPORT_FILE optional: a file to write what was shipped and indexed to
#
# CHART and VERSION come from outside the repository, so they are checked here
# before anything uses them. Requires cargueiro on PATH.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

CHART=${CHART:-}
VERSION=${VERSION:-}
REGISTRY=${REGISTRY:-}
[ -n "$CHART" ] || fail "the chart name is missing"
[ -n "$VERSION" ] || fail "the version is missing"
[ -n "$REGISTRY" ] || fail "the registry is missing"

# These only keep a value from being read as anything but a name or a version:
# cargueiro checks the chart against its rules, and the version against the
# version rules.
[[ "$CHART" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the chart name '$CHART' must be lower case letters, digits and dashes"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?(\+[0-9A-Za-z.-]+)?$ ]] ||
  fail "the version '$VERSION' must look like 1XY.Z.W+upA.B.C"

flags=()
if [ "${PLAIN_HTTP:-}" = "true" ]; then
  flags+=(--plain-http)
fi

repo=$PWD
reference="${REGISTRY}/${CHART}:${VERSION}"

echo "Shipping ${reference}"
shipped=$(cargueiro ship "$reference" --repo "$repo" ${flags[@]+"${flags[@]}"})

echo "Indexing"
indexed=$(cargueiro index --repo "$repo" --registry "$REGISTRY" ${flags[@]+"${flags[@]}"})

echo "Shipped:"
echo "$shipped"
echo "Index:"
echo "$indexed"

if [ -n "${REPORT_FILE:-}" ]; then
  {
    echo "Written by cargueiro ship:"
    printf '%s\n' "$shipped" | awk '{print "  " $0}'
    echo "Changed by cargueiro index:"
    printf '%s\n' "$indexed" | awk '{print "  " $0}'
  } >"$REPORT_FILE"
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### ${CHART} ${VERSION}"
    echo
    echo "Files written by \`cargueiro ship\`:"
    echo
    echo '```'
    echo "$shipped"
    echo '```'
    echo
    echo "Index changes from \`cargueiro index\`:"
    echo
    echo '```'
    echo "$indexed"
    echo '```'
  } >>"$GITHUB_STEP_SUMMARY"
fi
