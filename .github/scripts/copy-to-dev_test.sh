#!/usr/bin/env bash
# Tests copy-to-dev.sh in git repositories that are made here: a bare repository that plays GitHub, with a staging
# branch and the old dev-v2.16, and a clone of it where the script runs, as it does in the workflow.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/copy-to-dev.sh"
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT

pass=0
fail=0
check() { # check <name> <expected> <actual>
  if [ "$2" = "$3" ]; then
    echo "ok   - $1"
    pass=$((pass + 1))
  else
    echo "FAIL - $1 (expected '$2', got '$3')"
    fail=$((fail + 1))
  fi
}
git_in() { # git_in <dir> <git args>
  git -C "$@"
}
fresh() { # the remote with the two branches, a seed to change them, and a clone that has fetched them
  rm -rf "$DIR/remote.git" "$DIR/seed" "$DIR/work" "$DIR/result"
  git init -q --bare "$DIR/remote.git"
  git_in "$DIR/remote.git" symbolic-ref HEAD refs/heads/staging # the default branch, as in GitHub
  git init -q "$DIR/seed"
  git_in "$DIR/seed" config user.name test
  git_in "$DIR/seed" config user.email test@example.invalid
  git_in "$DIR/seed" config commit.gpgsign false
  # the old dev-v2.16: another tree than staging's, with an old .github
  git_in "$DIR/seed" checkout -q -b dev-v2.16
  mkdir -p "$DIR/seed/assets" "$DIR/seed/.github"
  echo old >"$DIR/seed/assets/old.tgz"
  echo old >"$DIR/seed/.github/old.yaml"
  git_in "$DIR/seed" add -A
  git_in "$DIR/seed" commit -q -m "old dev-v2.16"
  # staging: no history in common, as the real ones have little
  git_in "$DIR/seed" checkout -q --orphan staging
  git_in "$DIR/seed" rm -rq --cached .
  rm -rf "$DIR/seed/assets" "$DIR/seed/.github"
  mkdir -p "$DIR/seed/entries/fleet" "$DIR/seed/.github/workflows" "$DIR/seed/.github/scripts"
  echo "version: 1" >"$DIR/seed/entries/fleet/1.yaml"
  echo "entries: fleet" >"$DIR/seed/index.yaml"
  echo readme >"$DIR/seed/README"
  echo "on: push" >"$DIR/seed/.github/workflows/x.yaml"
  echo "echo y" >"$DIR/seed/.github/scripts/y.sh"
  git_in "$DIR/seed" add -A
  git_in "$DIR/seed" commit -q -m "staging"
  git_in "$DIR/seed" remote add origin "$DIR/remote.git"
  git_in "$DIR/seed" push -q origin staging dev-v2.16
  git clone -q "$DIR/remote.git" "$DIR/work"
  git_in "$DIR/work" config user.name test
  git_in "$DIR/work" config user.email test@example.invalid
}
stage() { # stage <message> <command run in the seed on the staging branch>; fetches it into the clone
  git_in "$DIR/seed" checkout -q staging
  (cd "$DIR/seed" && eval "$2")
  git_in "$DIR/seed" add -A
  git_in "$DIR/seed" commit -q -m "$1"
  git_in "$DIR/seed" push -q origin staging
  git_in "$DIR/work" fetch -q origin
}
run() { # run <env...>; prints the exit status
  rm -f "$DIR/result"
  (cd "$DIR/work" && env REMOTE=origin RESULT_FILE="$DIR/result" "$@" "$SCRIPT" >"$DIR/out" 2>"$DIR/err") && echo 0 || echo 1
}
res() { sed -n "s/^$1=//p" "$DIR/result"; } # a value of the result file
copy() { res copy; }
files() { git_in "$DIR/work" ls-tree -r --name-only "$1" | tr '\n' ' ' | sed 's/ $//'; }
adopt() { # the push of the copy, which is a fast-forward, and a fetch, as the clone sees it
  git_in "$DIR/work" push -q origin "$(copy):refs/heads/dev-v2.16"
  git_in "$DIR/work" fetch -q origin
}

fresh
before_head=$(git_in "$DIR/work" rev-parse HEAD)
before_refs=$(git_in "$DIR/work" for-each-ref | md5sum)
staging=$(git_in "$DIR/work" rev-parse refs/remotes/origin/staging)
old=$(git_in "$DIR/work" rev-parse refs/remotes/origin/dev-v2.16)
check "a copy is made" "0" "$(run)"
check "  the result says it was needed" "true" "$(res needed)"
check "  and names the commit of the source" "$staging" "$(res source)"
check "  the copy has the old dev-v2.16 as its only parent" "$old" "$(git_in "$DIR/work" rev-list --parents -n 1 "$(copy)" | cut -d' ' -f2-)"
check "  its tree is the one of staging without .github" "$(files refs/remotes/origin/staging | tr ' ' '\n' | grep -v '^\.github/' | tr '\n' ' ' | sed 's/ $//')" "$(files "$(copy)")"
check "  nothing of .github is in it" "0" "$(git_in "$DIR/work" ls-tree -r --name-only "$(copy)" | grep -c '^\.github/' || true)"
check "  nothing of the old dev-v2.16 is" "0" "$(git_in "$DIR/work" ls-tree -r --name-only "$(copy)" | grep -c '^assets/' || true)"
check "  the message says what was copied" "Copy staging at $staging" "$(git_in "$DIR/work" log -1 --format=%s "$(copy)")"
check "  the clone keeps its HEAD" "$before_head" "$(git_in "$DIR/work" rev-parse HEAD)"
check "  its working tree and index" "0" "$(git_in "$DIR/work" status --porcelain | wc -l)"
check "  and every ref it had (the copy is not on any branch)" "$before_refs" "$(git_in "$DIR/work" for-each-ref | md5sum)"

adopt
check "once the target has the copy there is nothing to copy" "0" "$(run)"
check "  the result says so" "false" "$(res needed)"
check "  and has no commit" "" "$(copy)"
check "  and the output says why" "1" "$(grep -c '^nothing to copy' "$DIR/out")"

stage "a change of the workflows" 'echo "on: pull_request" >.github/workflows/x.yaml; echo new >.github/scripts/z.sh'
check "a change that is only in .github needs no copy" "0" "$(run)"
check "  the result says so" "false" "$(res needed)"

stage "a new entry" 'echo "version: 2" >entries/fleet/2.yaml'
check "a change in the entries is copied" "0" "$(run)"
check "  it needs a copy" "true" "$(res needed)"
check "  and the copy adds only that file" "A	entries/fleet/2.yaml" "$(git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

stage "a deleted file" 'git rm -q README'
check "a file that staging deletes is deleted by the copy" "D	README" "$(run >/dev/null; git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

fresh
check "more than one path can be left out" "0" "$(run 'EXCLUDE=.github README')"
check "  all of them are" "entries/fleet/1.yaml index.yaml" "$(files "$(copy)")"
check "a path inside a folder can be left out alone" "0" "$(run EXCLUDE=.github/workflows)"
check "  and the rest of the folder stays" ".github/scripts/y.sh" "$(files "$(copy)" | tr ' ' '\n' | grep '^\.github/' | tr '\n' ' ' | sed 's/ $//')"
check "a path that is not there is not an error" "0" "$(run EXCLUDE=.github/nothing)"

check "the author is the one git is given" "0" "$(run GIT_AUTHOR_NAME=app-bot GIT_AUTHOR_EMAIL=app@example.invalid GIT_COMMITTER_NAME=app-bot GIT_COMMITTER_EMAIL=app@example.invalid)"
check "  author" "app-bot" "$(git_in "$DIR/work" log -1 --format=%an "$(copy)")"
check "  and committer" "app-bot" "$(git_in "$DIR/work" log -1 --format=%cn "$(copy)")"

check "the branches can be other than the defaults" "0" "$(run SOURCE_BRANCH=dev-v2.16 TARGET_BRANCH=staging)"
check "  and are the ones that were copied" "Copy dev-v2.16 at $(git_in "$DIR/work" rev-parse refs/remotes/origin/dev-v2.16)" "$(git_in "$DIR/work" log -1 --format=%s "$(copy)")"
check "no RESULT_FILE is fine" "0" "$( (cd "$DIR/work" && env REMOTE=origin "$SCRIPT" >/dev/null 2>&1) && echo 0 || echo 1)"

for bad in "TARGET_BRANCH=staging" "TARGET_BRANCH=a;b" "TARGET_BRANCH=-x" "TARGET_BRANCH=a b" "REMOTE=a;b" "EXCLUDE=../x" "EXCLUDE=a/../b" "EXCLUDE=/abs" "EXCLUDE=-rf" 'EXCLUDE=$(ls)'; do
  check "'$bad' is refused" "1" "$(run "$bad")"
  check "  with an error and no result" "1:0" "$(grep -c '^::error::' "$DIR/err" | tr -d '\n'):$([ -e "$DIR/result" ] && echo 1 || echo 0)"
done
check "a source that was not fetched is refused" "1" "$(run SOURCE_BRANCH=nothing)"
check "  and says to fetch it" "1" "$(grep -c 'fetch the branch first' "$DIR/err")"
check "a target that was not fetched is refused" "1" "$(run TARGET_BRANCH=nothing)"
check "a remote that was not fetched is refused" "1" "$(run REMOTE=nowhere)"

# A failure while the tree is made must stop the script: a command substitution does not inherit set -e, and the copy
# that was made after one would still have .github.
mkdir -p "$DIR/bin"
real_git=$(command -v git)
printf '#!/bin/sh\n[ "$1" = rm ] && { echo "git rm failed on purpose" >&2; exit 1; }\nexec %s "$@"\n' "$real_git" >"$DIR/bin/git"
chmod +x "$DIR/bin/git"
fresh
check "a git rm that fails stops the script" "1" "$(run "PATH=$DIR/bin:$PATH")"
check "  without a result, so nothing is copied" "0" "$([ -e "$DIR/result" ] && echo 1 || echo 0)"

echo
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
