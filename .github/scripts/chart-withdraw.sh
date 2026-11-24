#!/usr/bin/env bash
# Withdraws one version of a chart, or of a family of charts, from the staging
# catalog: runs `cargueiro withdraw` and then `cargueiro index` on the current
# directory, which must be an up to date checkout of the staging branch.
#
# It writes withdrawn: true to the entries (withdraw) and takes the versions out
# of the index (index). It does not commit or push: the workflow does, so the
# checks here can be run by hand.
#
# It only accepts:
#   - a chart that has no family: one that is released alone, with no crd or
#     extra chart next to it, or
#   - a family of charts, by the name of its main chart,
# and always one exact version, never a list, a range or a wildcard. Anything
# else is refused before anything is written, and so is a chart that belongs to
# a family of several charts: it is withdrawn with its family, never alone.
#
# Environment (CHART or FAMILY, never both):
#   CHART       the name of a chart that has no family
#   FAMILY      the name of a family, which is the name of its main chart: the
#               same version of every chart of it is withdrawn
#   VERSION     the one version, as in its entry (with the +)
#   DRY_RUN     optional: true to do every check and write nothing
#   REPORT_FILE optional: a file to write what was withdrawn and indexed to
#
# CHART, FAMILY and VERSION come from outside the repository, so they are checked
# here before anything uses them. Requires cargueiro on PATH.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

CHART=${CHART:-}
FAMILY=${FAMILY:-}
VERSION=${VERSION:-}
DRY_RUN=${DRY_RUN:-false}
[ -z "$CHART" ] || [ -z "$FAMILY" ] || fail "send a chart or a family, not both"
[ -n "$CHART" ] || [ -n "$FAMILY" ] || fail "the chart name or the family is missing"
[ -n "$VERSION" ] || fail "the version is missing"

# These only keep a value from being read as anything but a name or one version:
# cargueiro checks the entry against its rules. A list, a range, a wildcard, a
# space or a path cannot match.
[[ -z "$CHART" || "$CHART" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the chart name '$CHART' must be lower case letters, digits and dashes"
[[ -z "$FAMILY" || "$FAMILY" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the family name '$FAMILY' must be lower case letters, digits and dashes"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?(\+[0-9A-Za-z.-]+)?$ ]] ||
  fail "the version '$VERSION' must be one exact version, like 1XY.Z.W+upA.B.C"

name=${CHART:-$FAMILY}
entry="entries/${name}/${VERSION}.yaml"
[ -f "$entry" ] || fail "there is no entry $entry in this checkout: only a published version of a chart can be withdrawn"

# What would be withdrawn, main chart first, one "withdraw <chart> <version>"
# line each. The family flag is always given: for a chart that has no family it
# names the chart alone, and for any other it names the whole family, so the
# plan is how a chart that belongs to a family is told from one that has none.
echo "Dry run of withdraw"
plan=$(cargueiro withdraw --family --dry-run "$entry")
mapfile -t lines <<<"$plan"
first=$(awk '{print $2}' <<<"${lines[0]}")

if [ -n "$CHART" ]; then
  [ "${#lines[@]}" -eq 1 ] && [ "$first" = "$CHART" ] ||
    fail "the chart $CHART belongs to a family of ${#lines[@]} charts ($(awk '{print $2}' <<<"$plan" | paste -sd, -)): withdraw the family, by the name of its main chart ($first), and not the chart alone"
else
  [ "$first" = "$FAMILY" ] ||
    fail "$FAMILY is not the name of a family: the family of $FAMILY is $first, and it is withdrawn by that name"
fi
for line in "${lines[@]}"; do
  [ "$(awk '{print $3}' <<<"$line")" = "$VERSION" ] ||
    fail "the plan has a version that is not $VERSION: $line"
done

echo "To withdraw:"
echo "$plan"

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry run: nothing was written"
  echo "Dry run of index"
  cargueiro index --repo "$PWD" --dry-run --debug
  exit 0
fi

echo "Withdrawing"
withdrawn=$(cargueiro withdraw --family "$entry")
echo "Dry run of index"
cargueiro index --repo "$PWD" --dry-run --debug
echo "Indexing"
indexed=$(cargueiro index --repo "$PWD")

echo "Withdrawn:"
echo "$withdrawn"
echo "Index:"
echo "$indexed"

if [ -n "${REPORT_FILE:-}" ]; then
  {
    echo "Marked withdrawn by cargueiro withdraw:"
    printf '%s\n' "$withdrawn" | awk '{print "  " $0}'
    echo "Changed by cargueiro index:"
    printf '%s\n' "$indexed" | awk '{print "  " $0}'
  } >"$REPORT_FILE"
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### withdraw ${name} ${VERSION}"
    echo
    echo "Entries marked withdrawn:"
    echo
    echo '```'
    echo "$withdrawn"
    echo '```'
    echo
    echo "Index changes from \`cargueiro index\`:"
    echo
    echo '```'
    echo "$indexed"
    echo '```'
  } >>"$GITHUB_STEP_SUMMARY"
fi
