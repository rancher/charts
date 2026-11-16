#!/usr/bin/env bash
# Imports the versions of the old system, release-v2.15 of rancher/charts, into this
# checkout of the staging branch as legacy entries: pushes each chart to the staging
# registry if it is not there, and writes legacy/, assets/logos/ and index.yaml, one
# commit for each family. It does it with the legacy-import.sh script that cargueiro
# releases, the one of the release that is installed, and the rules.yaml of the same
# release, which says the families and the Rancher minors.
#
# It commits to the branch that is checked out, and does not push: the workflow does,
# so the checks here can be run by hand. It can be run again at any point: a family
# that is done has nothing to import and gets no commit.
#
# Environment:
#   FAMILY       optional: import only this family
#   DRY_RUN      "true" to report what would be imported and change nothing (default "false")
#   COMMITS_FILE optional: a file to write the number of commits that were made to
#   TOOLS_DIR    optional: where the script and the rules are downloaded to
#
# FAMILY and DRY_RUN come from outside the repository, so they are checked here
# before anything uses them. Requires cargueiro, curl and git on PATH, and git
# user.name and user.email set when it is not a dry run. The registry credentials
# are the ones cargueiro reads: CARGUEIRO_USERNAME and CARGUEIRO_PASSWORD.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

FAMILY=${FAMILY:-}
DRY_RUN=${DRY_RUN:-false}
COMMITS_FILE=${COMMITS_FILE:-}
TOOLS_DIR=${TOOLS_DIR:-$(mktemp -d)}

[[ -z "$FAMILY" || "$FAMILY" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the family name '$FAMILY' must be lower case letters, digits and dashes"
[[ "$DRY_RUN" == true || "$DRY_RUN" == false ]] || fail "DRY_RUN must be true or false, not '$DRY_RUN'"

# The release that is installed is the one whose script and rules are used.
installed=$(cargueiro version)
[[ "$installed" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
  fail "cargueiro is '$installed': a release is needed, to take its script and its rules"
raw="https://raw.githubusercontent.com/rancher/cargueiro/${installed}"
for file in tools/scripts/legacy-import.sh rules.yaml; do
  curl -fsSL "${raw}/${file}" -o "${TOOLS_DIR}/$(basename "$file")" ||
    fail "cannot download ${file} of cargueiro ${installed}"
done
echo "Importing with the script and the rules of cargueiro ${installed}"

args=(--repo "$PWD" --rules "${TOOLS_DIR}/rules.yaml")
[ -z "$FAMILY" ] || args+=(--family "$FAMILY")
[ "$DRY_RUN" = false ] || args+=(--dry-run)

before=$(git rev-parse HEAD)
bash "${TOOLS_DIR}/legacy-import.sh" "${args[@]}"

commits=$(git rev-list --count "${before}..HEAD")
echo "${commits} commits were made"
if [ -n "$COMMITS_FILE" ]; then
  echo "$commits" >"$COMMITS_FILE"
fi
