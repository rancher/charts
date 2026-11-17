#!/usr/bin/env bash
# Releases the legacy versions that the staging branch has to this checkout of the
# production branch: runs `cargueiro release --legacy`, which copies each chart from
# the staging registry to the production one and writes its entry to legacy/ and its
# logo to assets/logos/, then `cargueiro index`, and commits what was written: one
# commit for the versions and one for the index.
#
# A version that fails does not stop the others, so what went through is committed
# even when cargueiro release fails. The failure is in RESULT_FILE, and the workflow
# fails after it opened the pull request. It can be run again at any point: what is
# done has nothing to release.
#
# It commits to the branch that is checked out, and does not push: the workflow does,
# so the checks here can be run by hand.
#
# Environment:
#   STAGING_DIR  a checkout of the staging branch (required)
#   FAMILY       optional: release only the charts of this family, by its name in
#                rules.yaml. A release of everything is more than one run can copy
#   DRY_RUN      "true" to report what would be released and change nothing (default "false")
#   REPORT_FILE  optional: a file to write what cargueiro release printed to
#   RESULT_FILE  optional: a file to write status=<exit code of release> and
#                commits=<number of commits that were made> to, one a line
#
# FAMILY and DRY_RUN come from outside the repository, so they are checked here. Requires
# cargueiro on PATH, and git user.name and user.email set when it is not a dry run.
# The registry credentials are the ones cargueiro reads: CARGUEIRO_USERNAME and
# CARGUEIRO_PASSWORD for staging, CARGUEIRO_PRODUCTION_USERNAME and
# CARGUEIRO_PRODUCTION_PASSWORD for production.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

STAGING_DIR=${STAGING_DIR:-}
FAMILY=${FAMILY:-}
DRY_RUN=${DRY_RUN:-false}
REPORT_FILE=${REPORT_FILE:-$(mktemp)}
RESULT_FILE=${RESULT_FILE:-/dev/null}

[ -d "$STAGING_DIR" ] || fail "STAGING_DIR must be the checkout of the staging branch, not '$STAGING_DIR'"
[[ -z "$FAMILY" || "$FAMILY" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the family name '$FAMILY' must be lower case letters, digits and dashes"
[[ "$DRY_RUN" == true || "$DRY_RUN" == false ]] || fail "DRY_RUN must be true or false, not '$DRY_RUN'"

cargueiro release --help >/dev/null 2>&1 ||
  fail "this cargueiro ($(cargueiro version)) has no release command: install a release that has it"

args=(--legacy --from "$STAGING_DIR" --repo "$PWD")
[ -z "$FAMILY" ] || args+=(--family "$FAMILY")
[ "$DRY_RUN" = false ] || args+=(--dry-run)

# A version that did not go through is the status of release, kept for the end.
status=0
cargueiro release "${args[@]}" >"$REPORT_FILE" 2>&1 || status=$?
cat "$REPORT_FILE"

# What release writes: legacy/, and assets/logos/ only when a version has a logo of its
# own. git refuses a path that does not exist, so only the ones that do are given to it.
written=()
for path in legacy assets/logos; do
  [ ! -e "$path" ] || written+=("$path")
done

commits=0
if [ "$DRY_RUN" = false ] && [ ${#written[@]} -gt 0 ] && [ -n "$(git status --porcelain --untracked-files=all -- "${written[@]}")" ]; then
  git add -- "${written[@]}"
  # The summary of release starts at the line that counts the versions.
  {
    echo "legacy: release ${FAMILY:-the legacy versions} from staging"
    echo
    sed -n '/^released [0-9]* versions/,$p' "$REPORT_FILE"
  } >"${REPORT_FILE}.message"
  git commit -q --file "${REPORT_FILE}.message" -- "${written[@]}"
  commits=$((commits + 1))
  echo "committed the legacy versions"

  cargueiro index --repo .
  if [ -n "$(git status --porcelain -- index.yaml)" ]; then
    git add -- index.yaml
    git commit -q -m "legacy: regenerate the index" -- index.yaml
    commits=$((commits + 1))
    echo "committed the index"
  fi
fi

{
  echo "status=${status}"
  echo "commits=${commits}"
} >"$RESULT_FILE"
echo "release finished with status ${status}, ${commits} commits were made"
