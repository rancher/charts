#!/usr/bin/env bash
# Releases the new versions that the staging branch has to this checkout of the
# production branch: runs `cargueiro release`, which checks each chart, copies its
# images and the chart from the staging registry to the production one, and writes its
# entry to entries/ and its logo to assets/logos/, then `cargueiro index`, which pulls
# the archives from the production registry into assets/ and writes index.yaml, and
# commits what was written: one commit for the versions and one for the archives and
# the index.
#
# Before it, the images of the versions to release are looked for on Docker Hub, and a missing
# one stops the script with nothing copied.
#
# The registries are written by cargueiro release itself, while it runs, not by the
# pull request that comes after: by the time there is something to commit, the images
# and the charts of those versions are in the production registry. A dry run reads
# both checkouts only and writes nothing anywhere.
#
# A version that fails does not stop the others, so what went through is committed even
# when cargueiro release fails. The failure is in RESULT_FILE, and the workflow fails
# after it opened the pull request. It can be run again at any point: what is done has
# nothing to release.
#
# It commits to the branch that is checked out, and does not push: the workflow does, so
# the checks here can be run by hand.
#
# Environment:
#   STAGING_DIR          a checkout of the staging branch (required)
#   PRODUCTION_REGISTRY  the registry path the entries point to and the archives are pulled
#                        from, host/path with no scheme, such as registry.suse.com/rancher/catalog
#                        (required; it is fixed by the workflow, never taken from the event)
#   FAMILY               optional: release only the charts of this family, by its name in rules.yaml
#   DRY_RUN              "true" to report what would be released and change nothing (default "false")
#   REPORT_FILE          optional: a file to write what cargueiro release printed to
#   RESULT_FILE          optional: a file to write status=<exit code of release> and
#                        commits=<number of commits that were made> to, one a line
#
# FAMILY and DRY_RUN come from outside the repository, so they are checked here. Requires
# cargueiro on PATH, and git user.name and user.email set when it is not a dry run. The
# registry credentials are the ones cargueiro reads: CARGUEIRO_USERNAME and
# CARGUEIRO_PASSWORD for staging, CARGUEIRO_PRODUCTION_USERNAME and
# CARGUEIRO_PRODUCTION_PASSWORD for production. The index is made without the staging
# ones: the production registry is read anonymously, as the audit of the pull request does.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

STAGING_DIR=${STAGING_DIR:-}
PRODUCTION_REGISTRY=${PRODUCTION_REGISTRY:-}
FAMILY=${FAMILY:-}
DRY_RUN=${DRY_RUN:-false}
REPORT_FILE=${REPORT_FILE:-$(mktemp)}
RESULT_FILE=${RESULT_FILE:-/dev/null}

[ -d "$STAGING_DIR" ] || fail "STAGING_DIR must be the checkout of the staging branch, not '$STAGING_DIR'"
[[ "$PRODUCTION_REGISTRY" =~ ^[a-z0-9.-]+(:[0-9]+)?(/[a-z0-9._-]+)+$ ]] ||
  fail "PRODUCTION_REGISTRY must be host/path with no scheme, not '$PRODUCTION_REGISTRY'"
[[ -z "$FAMILY" || "$FAMILY" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] ||
  fail "the family name '$FAMILY' must be lower case letters, digits and dashes"
[[ "$DRY_RUN" == true || "$DRY_RUN" == false ]] || fail "DRY_RUN must be true or false, not '$DRY_RUN'"

cargueiro release --help >/dev/null 2>&1 ||
  fail "this cargueiro ($(cargueiro version)) has no release command: install a release that has it"

args=(--from "$STAGING_DIR" --repo "$PWD")
[ -z "$FAMILY" ] || args+=(--family "$FAMILY")
[ "$DRY_RUN" = false ] || args+=(--dry-run)

# The community pulls the images from Docker Hub, and the air-gap image list names them
# there, but release only copies them between the SUSE registries. So before anything is
# copied, which cannot be undone, the images of every version that would be released are
# looked for on Docker Hub. The dry run says which versions those are, family included, and
# reads no registry. The archive of each is the one staging has in assets/. Every version is
# checked before the script fails, so all the missing images are reported together. A dry run
# of the workflow does the same check, so it shows what a real run would stop on.
check_docker_hub() {
  local plan="$1" workdir failed=0 chart version archive
  workdir=$(mktemp -d)
  while read -r _ chart version; do
    archive="$STAGING_DIR/assets/$chart/$chart-$version.tgz"
    if [ ! -f "$archive" ]; then
      echo "::error::staging has no archive for $chart $version at assets/$chart/$chart-$version.tgz"
      failed=1
      continue
    fi
    mkdir -p "$workdir/$chart-$version"
    tar -xzf "$archive" -C "$workdir/$chart-$version"
    echo "Docker Hub: $chart $version"
    # The images are printed on success: only the failures are of interest here.
    cargueiro check-pushed-dependencies "$workdir/$chart-$version/$chart" --registry docker.io >/dev/null || failed=1
  done < <(grep -E '^release ' "$plan" || true)
  rm -rf "$workdir"
  return "$failed"
}

plan="${REPORT_FILE}.plan"
cargueiro release "${args[@]}" --dry-run >"$plan" 2>&1 || {
  cat "$plan"
  fail "cargueiro release --dry-run failed: nothing was released"
}
check_docker_hub "$plan" ||
  fail "some images of the versions to release are not on Docker Hub: nothing was released. Push them there and run this again"

# A version that did not go through is the status of release, kept for the end.
status=0
cargueiro release "${args[@]}" >"$REPORT_FILE" 2>&1 || status=$?
cat "$REPORT_FILE"

# What release writes: entries/, and assets/logos/ only when a version has a logo of its
# own. git refuses a path that does not exist, so only the ones that do are given to it.
written=()
for path in entries assets/logos; do
  [ ! -e "$path" ] || written+=("$path")
done

commits=0
if [ "$DRY_RUN" = false ] && [ ${#written[@]} -gt 0 ] && [ -n "$(git status --porcelain --untracked-files=all -- "${written[@]}")" ]; then
  git add -- "${written[@]}"
  # The summary of release starts at the line that counts the versions.
  {
    echo "release: the new versions${FAMILY:+ of $FAMILY} from staging"
    echo
    sed -n '/^released [0-9]* versions/,$p' "$REPORT_FILE"
  } >"${REPORT_FILE}.message"
  git commit -q --file "${REPORT_FILE}.message" -- "${written[@]}"
  commits=$((commits + 1))
  echo "committed the new versions"

  # The archives are pulled from the production registry, where release just put them.
  env -u CARGUEIRO_USERNAME -u CARGUEIRO_PASSWORD cargueiro index --repo . --registry "$PRODUCTION_REGISTRY"
  if [ -n "$(git status --porcelain --untracked-files=all -- assets index.yaml)" ]; then
    git add -- assets index.yaml
    git commit -q -m "release: add the archives and regenerate the index" -- assets index.yaml
    commits=$((commits + 1))
    echo "committed the archives and the index"
  fi
fi

{
  echo "status=${status}"
  echo "commits=${commits}"
} >"$RESULT_FILE"
echo "release finished with status ${status}, ${commits} commits were made"
