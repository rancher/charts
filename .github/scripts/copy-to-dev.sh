#!/usr/bin/env bash
# Makes the commit that copies some paths of one branch to another, in one commit, and leaves everything else of the
# target as it is.
#
# The git mirror serves dev-v2.16 and release-v2.16 and not staging and production, so after a merge the catalog is
# copied from the one to the other. The commit has the tree of the head of TARGET_BRANCH in which the INCLUDE paths are
# the ones of the head of SOURCE_BRANCH: a path that the source does not have any more is removed from the target, and
# any file of the target that is not under an INCLUDE path stays as it is, such as its .github and the files of GitHub
# Pages (CNAME, _config.yml, index.html). So the script relies on the first copy having been made by hand, which also
# took out of the target what it must not have: it never removes a file that is not under an INCLUDE path.
#
# The head of the target is the only parent of the commit, so pushing it is a fast-forward and nothing is ever forced.
# When the target has the tree already there is nothing to copy and no commit is made.
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
#   INCLUDE        the paths that are copied, separated by spaces: files or folders (default index.yaml assets entries legacy)
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
INCLUDE=${INCLUDE:-index.yaml assets entries legacy}
DRY_RUN=${DRY_RUN:-false}
RESULT_FILE=${RESULT_FILE:-/dev/null}

# These come from outside the repository, so they are checked before they are used.
for name in SOURCE_BRANCH TARGET_BRANCH REMOTE; do
  [[ "${!name}" =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]] || fail "$name must be a branch or remote name, not '${!name}'"
done
for path in $INCLUDE; do
  [[ "$path" =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ && "$path" != *..* ]] || fail "INCLUDE has '$path', which is not a path inside the repository"
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

# The tree of the target with the INCLUDE paths of the source, made in an index of its own, so that no file is checked
# out and the index and the working tree of the caller stay as they are. A path is taken out of the index and the one of
# the source is put in its place, which is also how one that the source does not have is removed. The index is not the one
# of a checkout, so git rm is forced: without -f it refuses an entry that is not the one of HEAD and the working tree. A
# command substitution does not inherit set -e, hence the one inside it: a failure here must stop the script and not give
# a tree that has the old paths.
index=$(mktemp -u)
trap 'rm -f "$index"' EXIT
tree=$(
  set -e
  export GIT_INDEX_FILE="$index"
  git read-tree "$target_sha"
  for path in $INCLUDE; do
    git rm -r -q -f --cached --ignore-unmatch -- "$path"
    git ls-tree -r -z "$source_sha" -- "$path" | git update-index -z --index-info
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
