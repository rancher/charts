#!/usr/bin/env bash
# Tests copy-to-dev.sh in git repositories that are made here: a bare repository that plays GitHub, with a staging
# branch and the old dev-v2.16, and a clone of it where the script runs, as it does in the workflow.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/copy-to-dev.sh"
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
export LC_ALL=C

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
  # the target, as the manual copy left it: an old catalog, and files that are its own and must stay
  git_in "$DIR/seed" checkout -q -b dev-v2.16
  mkdir -p "$DIR/seed/assets" "$DIR/seed/.github"
  echo old >"$DIR/seed/assets/old.tgz"
  echo "its own workflow" >"$DIR/seed/.github/old.yaml"
  echo "charts.example.invalid" >"$DIR/seed/CNAME"
  echo "exclude: [entries, legacy]" >"$DIR/seed/_config.yml"
  echo "readme of the target" >"$DIR/seed/README.md"
  echo "ignore of the target" >"$DIR/seed/.gitignore"
  git_in "$DIR/seed" add -A
  git_in "$DIR/seed" commit -q -m "old dev-v2.16"
  # staging: no history in common, as the real ones have little
  git_in "$DIR/seed" checkout -q --orphan staging
  git_in "$DIR/seed" rm -rq --cached .
  rm -rf "$DIR/seed/assets" "$DIR/seed/.github" "$DIR/seed/CNAME" "$DIR/seed/_config.yml" "$DIR/seed/README.md" "$DIR/seed/.gitignore"
  mkdir -p "$DIR/seed/entries/fleet" "$DIR/seed/legacy/fleet" "$DIR/seed/assets/fleet" "$DIR/seed/assets/logos" \
    "$DIR/seed/docs" "$DIR/seed/.github/workflows" "$DIR/seed/.github/scripts"
  echo "version: 1" >"$DIR/seed/entries/fleet/1.yaml"
  echo "version: 0" >"$DIR/seed/legacy/fleet/0.yaml"
  echo "entries: fleet" >"$DIR/seed/index.yaml"
  echo archive >"$DIR/seed/assets/fleet/fleet-1.tgz"
  echo logo >"$DIR/seed/assets/logos/fleet.png"
  echo "readme of staging" >"$DIR/seed/README.md"
  echo "ignore of staging" >"$DIR/seed/.gitignore"
  echo doc >"$DIR/seed/docs/d.md"
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
run() { # run <env...>; prints the exit status. It is a dry run unless the caller says DRY_RUN=false
  rm -f "$DIR/result"
  (cd "$DIR/work" && env REMOTE=origin DRY_RUN=true RESULT_FILE="$DIR/result" "$@" "$SCRIPT" >"$DIR/out" 2>"$DIR/err") && echo 0 || echo 1
}
res() { sed -n "s/^$1=//p" "$DIR/result"; } # a value of the result file
copy() { res copy; }
remote_head() { git_in "$DIR/remote.git" rev-parse "refs/heads/$1"; } # a branch of the remote, as GitHub has it
list() { tr '\n' ' ' | sed 's/ $//'; } # the lines of the input, on one line
sorted() { tr ' ' '\n' | sort | list; } # the words of the input, sorted, on one line
files() { git_in "$DIR/work" ls-tree -r --name-only "$1" | sort | list; }
remote_files() { git_in "$DIR/remote.git" ls-tree -r --name-only "$1" | sort | list; }
expected() { # expected <target> <source>: the files that the default paths give, the ones of the target that are not in them, and the ones of the source that are
  {
    git_in "$DIR/work" ls-tree -r --name-only "$1" | grep -v -E '^(index\.yaml$|assets/|entries/|legacy/|README\.md$|\.gitignore$)' || true
    git_in "$DIR/work" ls-tree -r --name-only "$2" | grep -E '^(index\.yaml$|assets/|entries/|legacy/|README\.md$|\.gitignore$)' || true
  } | sort | list
}
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
check "  it has the target's own files and the paths of the source" "$(echo ".github/old.yaml CNAME _config.yml .gitignore README.md assets/fleet/fleet-1.tgz assets/logos/fleet.png entries/fleet/1.yaml index.yaml legacy/fleet/0.yaml" | sorted)" "$(files "$(copy)")"
check "  which is what the paths give" "$(expected refs/remotes/origin/dev-v2.16 refs/remotes/origin/staging)" "$(files "$(copy)")"
mine=""
for f in CNAME _config.yml .github/old.yaml; do
  if [ "$(git_in "$DIR/work" rev-parse "$(copy):$f")" = "$(git_in "$DIR/work" rev-parse "$old:$f")" ]; then mine="$mine $f"; fi
done
check "  the files of the target that are not in the paths are the same blobs" " CNAME _config.yml .github/old.yaml" "$mine"
check "  and the README and .gitignore are the ones of staging" "readme of staging:ignore of staging" "$(git_in "$DIR/work" show "$(copy):README.md"):$(git_in "$DIR/work" show "$(copy):.gitignore")"
check "  nothing of staging outside the paths is copied" "0" "$(git_in "$DIR/work" ls-tree -r --name-only "$(copy)" | grep -c -E '^(docs/|\.github/(workflows|scripts)/)' || true)"
check "  the old catalog of the target is replaced" "0" "$(git_in "$DIR/work" ls-tree -r --name-only "$(copy)" | grep -c '^assets/old.tgz' || true)"
check "  the message says what was copied" "Copy staging at $staging" "$(git_in "$DIR/work" log -1 --format=%s "$(copy)")"
check "  the clone keeps its HEAD" "$before_head" "$(git_in "$DIR/work" rev-parse HEAD)"
check "  its working tree and index" "0" "$(git_in "$DIR/work" status --porcelain | wc -l)"
check "  and every ref it had (the copy is not on any branch)" "$before_refs" "$(git_in "$DIR/work" for-each-ref | md5sum)"

adopt
check "once the target has the copy there is nothing to copy" "0" "$(run)"
check "  the result says so" "false" "$(res needed)"
check "  and has no commit" "" "$(copy)"
check "  and the output says why" "1" "$(grep -c '^nothing to copy' "$DIR/out")"

stage "changes outside the paths" 'echo changed >docs/d.md; echo "on: pull_request" >.github/workflows/x.yaml; echo new >.github/scripts/z.sh'
check "a change that is outside the paths needs no copy" "0" "$(run)"
check "  the result says so" "false" "$(res needed)"

stage "a changed README" 'echo "a new line" >>README.md'
check "a change of the README is copied" "0" "$(run)"
check "  and is the only change" "M	README.md" "$(git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

stage "a new entry" 'echo "version: 2" >entries/fleet/2.yaml'
check "a change in the entries is copied" "0" "$(run)"
check "  it needs a copy" "true" "$(res needed)"
check "  and the copy adds only that file" "A	entries/fleet/2.yaml" "$(git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

stage "a deleted entry" 'git rm -q entries/fleet/1.yaml'
check "a file in the paths that staging deletes is deleted by the copy" "D	entries/fleet/1.yaml" "$(run >/dev/null; git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

stage "no legacy any more" 'git rm -rq legacy'
check "a folder in the paths that staging does not have any more is removed" "D	legacy/fleet/0.yaml" "$(run >/dev/null; git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
adopt

stage "a deleted file outside the paths" 'git rm -q docs/d.md'
check "a file outside the paths that staging deletes is not deleted by the copy" "false" "$(run >/dev/null; res needed)"

fresh
check "other paths can be given" "0" "$(run 'INCLUDE=index.yaml entries')"
check "  only those are copied, and the rest of the target stays" "$(echo ".github/old.yaml CNAME _config.yml .gitignore README.md assets/old.tgz entries/fleet/1.yaml index.yaml" | sorted)" "$(files "$(copy)")"
check "  so the README of the target is its own" "readme of the target" "$(git_in "$DIR/work" show "$(copy):README.md")"
check "a path inside a folder can be given alone" "0" "$(run INCLUDE=assets/logos)"
check "  and the rest of the folder stays as the target has it" "$(echo ".github/old.yaml CNAME _config.yml .gitignore README.md assets/logos/fleet.png assets/old.tgz" | sorted)" "$(files "$(copy)")"
check "a file can be given alone" "0" "$(run INCLUDE=index.yaml)"
check "  and is the only change" "A	index.yaml" "$(git_in "$DIR/work" diff --name-status refs/remotes/origin/dev-v2.16 "$(copy)")"
check "a path that neither branch has is not an error" "0" "$(run INCLUDE=nothing)"
check "  and there is nothing to copy" "false" "$(res needed)"

check "the author is the one git is given" "0" "$(run GIT_AUTHOR_NAME=app-bot GIT_AUTHOR_EMAIL=app@example.invalid GIT_COMMITTER_NAME=app-bot GIT_COMMITTER_EMAIL=app@example.invalid)"
check "  author" "app-bot" "$(git_in "$DIR/work" log -1 --format=%an "$(copy)")"
check "  and committer" "app-bot" "$(git_in "$DIR/work" log -1 --format=%cn "$(copy)")"

check "the branches can be other than the defaults" "0" "$(run SOURCE_BRANCH=dev-v2.16 TARGET_BRANCH=staging)"
check "  and are the ones that were copied" "Copy dev-v2.16 at $(git_in "$DIR/work" rev-parse refs/remotes/origin/dev-v2.16)" "$(git_in "$DIR/work" log -1 --format=%s "$(copy)")"
check "no RESULT_FILE is fine" "0" "$( (cd "$DIR/work" && env REMOTE=origin DRY_RUN=true "$SCRIPT" >/dev/null 2>&1) && echo 0 || echo 1)"

fresh
old=$(git_in "$DIR/work" rev-parse refs/remotes/origin/dev-v2.16)
check "a dry run makes the copy and pushes nothing" "0" "$(run)"
check "  the result says it was needed and not pushed" "true:false" "$(res needed):$(res pushed)"
check "  the output says it is a dry run" "1" "$(grep -c '^dry run: ' "$DIR/out")"
check "  and dev-v2.16 of the remote is as it was" "$old" "$(remote_head dev-v2.16)"

fresh
old=$(remote_head dev-v2.16)
staging=$(remote_head staging)
check "a real run pushes the copy" "0" "$(run DRY_RUN=false)"
check "  the result says it was needed and pushed" "true:true" "$(res needed):$(res pushed)"
check "  dev-v2.16 of the remote is the copy" "$(copy)" "$(remote_head dev-v2.16)"
check "  and the old head is its parent, so it was a fast-forward" "$old" "$(git_in "$DIR/remote.git" rev-parse "$(copy)^")"
check "  staging of the remote is untouched" "$staging" "$(remote_head staging)"
check "  the remote has the files of the target and the paths of staging" "$(expected refs/remotes/origin/dev-v2.16 refs/remotes/origin/staging)" "$(remote_files dev-v2.16)"
pushed_head=$(remote_head dev-v2.16)
check "a second real run has nothing to push" "0" "$(run DRY_RUN=false)"
check "  the result says so" "false:false" "$(res needed):$(res pushed)"
check "  and dev-v2.16 of the remote is the same" "$pushed_head" "$(remote_head dev-v2.16)"

fresh
git_in "$DIR/seed" checkout -q dev-v2.16
echo other >"$DIR/seed/other.txt"
git_in "$DIR/seed" add -A
git_in "$DIR/seed" commit -q -m "pushed by someone else after the clone fetched"
git_in "$DIR/seed" push -q origin dev-v2.16
other=$(remote_head dev-v2.16)
check "a target that moved after the fetch is not forced" "1" "$(run DRY_RUN=false)"
check "  what the other push did is still there" "$other" "$(remote_head dev-v2.16)"
check "  the error says the copy was not pushed" "1" "$(grep -c '^::error::the copy was not pushed' "$DIR/err")"
check "  and there is no result" "0" "$([ -e "$DIR/result" ] && echo 1 || echo 0)"

for bad in "TARGET_BRANCH=staging" "TARGET_BRANCH=a;b" "TARGET_BRANCH=-x" "TARGET_BRANCH=a b" "REMOTE=a;b" "INCLUDE=../x" "INCLUDE=a/../b" "INCLUDE=/abs" "INCLUDE=-rf" "DRY_RUN=yes" "DRY_RUN=TRUE" 'INCLUDE=$(ls)'; do
  check "'$bad' is refused" "1" "$(run "$bad")"
  check "  with an error and no result" "1:0" "$(grep -c '^::error::' "$DIR/err" | tr -d '\n'):$([ -e "$DIR/result" ] && echo 1 || echo 0)"
done
check "a source that was not fetched is refused" "1" "$(run SOURCE_BRANCH=nothing)"
check "  and says to fetch it" "1" "$(grep -c 'fetch the branch first' "$DIR/err")"
check "a target that was not fetched is refused" "1" "$(run TARGET_BRANCH=nothing)"
check "a remote that was not fetched is refused" "1" "$(run REMOTE=nowhere)"

# A failure while the tree is made must stop the script: a command substitution does not inherit set -e, and the copy
# that was made after one would still have the old paths. The stand-in for git fails on the command in FAIL_ON.
mkdir -p "$DIR/bin"
real_git=$(command -v git)
printf '#!/bin/sh\n[ "$1" = "${FAIL_ON:-}" ] && { echo "git $1 failed on purpose" >&2; exit 1; }\nexec %s "$@"\n' "$real_git" >"$DIR/bin/git"
chmod +x "$DIR/bin/git"
fresh
for cmd in rm update-index write-tree; do
  check "a git $cmd that fails stops the script" "1" "$(run "PATH=$DIR/bin:$PATH" "FAIL_ON=$cmd")"
  check "  without a result, so nothing is copied" "0" "$([ -e "$DIR/result" ] && echo 1 || echo 0)"
done

echo
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
