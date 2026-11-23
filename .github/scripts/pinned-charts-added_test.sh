#!/usr/bin/env bash
# Tests pinned-charts-added.sh against a repository that is made here.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/pinned-charts-added.sh"
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
cd "$DIR"
git init -q .
git config user.name test
git config user.email test@example.invalid
git config commit.gpgsign false

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
commit() { # commit <message>, with whatever is staged
  git add -A
  git commit -q -m "$1"
  git rev-parse HEAD
}
add() { mkdir -p "entries/$1"; echo "version: $2" >"entries/$1/$2.yaml"; }
run() { BEFORE="$1" AFTER="$2" "$SCRIPT" | tr '\n' ' ' | sed 's/ $//'; }

echo init >README
base=$(commit "init")

add rancher-webhook 111.0.1+up0.9.1
c1=$(commit "[staging] ship rancher-webhook 111.0.1+up0.9.1")
check "a pinned chart that is added" "rancher-webhook" "$(run "$base" "$c1")"

add rancher-monitoring 111.0.0+up80.9.1
c2=$(commit "[staging] ship rancher-monitoring 111.0.0+up80.9.1")
check "a chart that is not pinned prints nothing" "" "$(run "$c1" "$c2")"

add fleet 111.0.1+up0.17.0
add fleet-agent 111.0.1+up0.17.0
add fleet-crd 111.0.1+up0.17.0
c3=$(commit "[staging] ship fleet 111.0.1+up0.17.0")
check "a family: only the pinned member is named" "fleet" "$(run "$c2" "$c3")"

echo "hidden: true" >>entries/rancher-webhook/111.0.1+up0.9.1.yaml
c4=$(commit "[staging] hide rancher-webhook 111.0.1+up0.9.1")
check "a version that is changed is not a new one" "" "$(run "$c3" "$c4")"

git rm -q entries/rancher-webhook/111.0.1+up0.9.1.yaml
c5=$(commit "[staging] withdraw rancher-webhook 111.0.1+up0.9.1")
check "a version that is withdrawn is not a new one" "" "$(run "$c4" "$c5")"

check "several commits: the range is looked at as a whole" "fleet rancher-webhook" "$(run "$base" "$c3")"

add rancher-turtles 111.0.0+up0.28.0
add rancher-turtles 111.0.0+up0.28.1
c6=$(commit "[staging] ship rancher-turtles twice")
check "two versions of a chart are named once" "rancher-turtles" "$(run "$c5" "$c6")"

check "the branch was created: all zeros looks at the commit alone" "rancher-turtles" "$(run 0000000000000000000000000000000000000000 "$c6")"
check "a before that is not in the clone looks at the commit alone" "rancher-turtles" "$(run deadbeefdeadbeefdeadbeefdeadbeefdeadbeef "$c6")"
check "an empty before looks at the commit alone" "rancher-turtles" "$(run "" "$c6")"

mkdir -p assets/fleet && echo x >assets/fleet/fleet-1.tgz && echo "a: 1" >index.yaml
c7=$(commit "[staging] only an archive and the index")
check "files outside entries/ are not looked at" "" "$(run "$c6" "$c7")"

add rancher-eks-operator-crd 111.0.0+up1.16.0
c8=$(commit "[staging] ship a chart whose name starts like a pinned one")
check "a name that only starts like a pinned one does not match" "" "$(run "$c7" "$c8")"

check "PINNED can be changed" "rancher-monitoring" "$(PINNED=rancher-monitoring run "$base" "$c2")"

if AFTER="" "$SCRIPT" >/dev/null 2>&1; then
  check "AFTER is required" "fails" "passes"
else
  check "AFTER is required" "fails" "fails"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
