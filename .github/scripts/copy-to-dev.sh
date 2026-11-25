#!/usr/bin/env bash
# Makes the commit that copies one branch to another, in one commit, without the paths that the copy
# leaves out (.github by default).
#
# The git mirror serves dev-v2.16 and not staging, so the staging branch is copied to dev-v2.16 after every
# merge. The commit has the tree of the head of SOURCE_BRANCH without the left-out paths, and the head of
# TARGET_BRANCH as its only parent, so that pushing it to the target is a fast-forward and nothing is ever
# forced. When the target has that tree already there is nothing to copy and no commit is made.
#
# The branches are read from REMOTE as the caller fetched them (refs/remotes/$REMOTE/<branch>). The commit is
# pushed to TARGET_BRANCH of REMOTE with a plain git push, never forced: git refuses it when the target is not
# at the commit the copy was made on, which is what happens when someone else pushed in between, and then the
# script fails and changes nothing. The next run copies again on the new head. With DRY_RUN the commit is made and
# nothing is pushed.
#
# Environment:
#   SOURCE_BRANCH  the branch that is copied (default staging)
#   TARGET_BRANCH  the branch that gets the copy (default dev-v2.16)
#   REMOTE         the remote they were fetched from (default origin)
#   EXCLUDE        paths that are left out of the copy, separated by spaces (default .github)
#   DRY_RUN        true to make the commit and push nothing, false to push it (default false)
#   RESULT_FILE    optional: gets needed=true|false, source=<commit of the source>, copy=<the new commit, or empty>
#                  and pushed=true|false
#
# The author and the committer of the commit are the ones git is given: GIT_AUTHOR_NAME and the like, or its config.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

SOURCE_BRANCH=${SOURCE_BRANCH:-staging}
TARGET_BRANCH=${TARGET_BRANCH:-dev-v2.16}
REMOTE=${REMOTE:-origin}
EXCLUDE=${EXCLUDE:-.github}
DRY_RUN=${DRY_RUN:-false}
RESULT_FILE=${RESULT_FILE:-/dev/null}

# These come from outside the repository, so they are checked before they are used.
for name in SOURCE_BRANCH TARGET_BRANCH REMOTE; do
  [[ "${!name}" =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]] || fail "$name must be a branch or remote name, not '${!name}'"
done
for path in $EXCLUDE; do
  [[ "$path" =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ && "$path" != *..* ]] || fail "EXCLUDE has '$path', which is not a path inside the repository"
done
[[ "$DRY_RUN" == true || "$DRY_RUN" == false ]] || fail "DRY_RUN must be true or false, not '$DRY_RUN'"
[ "$SOURCE_BRANCH" != "$TARGET_BRANCH" ] || fail "SOURCE_BRANCH and TARGET_BRANCH are both $SOURCE_BRANCH"

source_ref="refs/remotes/$REMOTE/$SOURCE_BRANCH"
target_ref="refs/remotes/$REMOTE/$TARGET_BRANCH"
for ref in "$source_ref" "$target_ref"; do
  git rev-parse --verify --quiet "$ref^{commit}" >/dev/null || fail "$ref is not in this repository: fetch the branch first"
done
source_sha=$(git rev-parse "$source_ref")
target_sha=$(git rev-parse "$target_ref")

# The tree of the source without what is left out, made in an index of its own, so that no file is checked out
# and the index and the working tree of the caller stay as they are. The index is not the one of a checkout, so
# git rm is forced: without -f it refuses an entry that is not the one of HEAD and the working tree, which is the
# case whenever the source has moved since the checkout. A command substitution does not inherit set -e, hence the
# one inside it: a failure here must stop the script and not give a tree that still has what had to be left out.
index=$(mktemp -u)
trap 'rm -f "$index"' EXIT
tree=$(
  set -e
  export GIT_INDEX_FILE="$index"
  git read-tree "$source_sha"
  for path in $EXCLUDE; do
    git rm -r -q -f --cached --ignore-unmatch -- "$path"
  done
  git write-tree
)

copy=""
needed=false
pushed=false
if [ "$tree" = "$(git rev-parse "$target_sha^{tree}")" ]; then
  echo "nothing to copy: $TARGET_BRANCH already has the tree of $SOURCE_BRANCH at ${source_sha:0:9}"
else
  needed=true
  copy=$(git commit-tree "$tree" -p "$target_sha" -m "Copy $SOURCE_BRANCH at $source_sha")
  echo "copy of $SOURCE_BRANCH at ${source_sha:0:9} on top of $TARGET_BRANCH at ${target_sha:0:9}: ${copy:0:9}"
  git -c diff.renames=false diff --shortstat "$target_sha" "$copy" | sed 's/^ /  /'

  if [ "$DRY_RUN" = true ]; then
    echo "dry run: ${copy:0:9} is not pushed to $REMOTE/$TARGET_BRANCH"
  else
    # No + and no --force: git itself refuses anything that is not a fast-forward of the target.
    git push -q "$REMOTE" "$copy:refs/heads/$TARGET_BRANCH" ||
      fail "the copy was not pushed to $REMOTE/$TARGET_BRANCH, which is not at ${target_sha:0:9} any more: nothing was changed, and the next run copies again"
    pushed=true
    echo "pushed ${copy:0:9} to $REMOTE/$TARGET_BRANCH"
  fi
fi

{
  echo "needed=$needed"
  echo "source=$source_sha"
  echo "copy=$copy"
  echo "pushed=$pushed"
} >"$RESULT_FILE"
