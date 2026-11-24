#!/usr/bin/env bash
# Tests chart-released.sh with a stand-in for cargueiro, in a git repository that is made here.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/chart-released.sh"
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
mkdir "$DIR/bin" "$DIR/staging"

cat >"$DIR/bin/cargueiro" <<'STUB'
#!/usr/bin/env bash
# Stand-in: only the calls the script makes. STUB_LOG gets each call and the staging
# credentials it saw; STUB_MODE says what release does.
case "$1" in
  version) echo v0.0.0-stub; exit 0 ;;
  release)
    [ "${2:-}" != "--help" ] || exit 0
    echo "release $*" >>"$STUB_LOG"
    case "${STUB_MODE:-ok}" in
      ok)
        case " $* " in *" --dry-run "*) echo "release fleet 111.0.1+up0.17.0"; exit 0 ;; esac
        mkdir -p entries/fleet assets/logos
        echo "version: 111.0.1+up0.17.0" >entries/fleet/111.0.1+up0.17.0.yaml
        echo logo >assets/logos/fleet.png
        printf 'released 1 versions, adopted 0\n  fleet 111.0.1+up0.17.0\n'
        ;;
      partial)
        mkdir -p entries/fleet
        echo "version: 111.0.1+up0.17.0" >entries/fleet/111.0.1+up0.17.0.yaml
        printf 'released 1 versions, adopted 0, failed 1, in conflict 0\nFAILED: longhorn 111.0.0+up1.11.3\n'
        exit 1
        ;;
      none) echo "nothing to release" ;;
    esac
    ;;
  index)
    echo "index ${*:2} | staging user='${CARGUEIRO_USERNAME:-}' pass='${CARGUEIRO_PASSWORD:-}'" >>"$STUB_LOG"
    mkdir -p assets/fleet
    echo archive >assets/fleet/fleet-111.0.1+up0.17.0.tgz
    echo "entries: fleet" >index.yaml
    ;;
esac
STUB
chmod +x "$DIR/bin/cargueiro"
export PATH="$DIR/bin:$PATH"
export STUB_LOG="$DIR/log"

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
fresh() { # a new production checkout
  rm -rf "$DIR/prod"
  mkdir "$DIR/prod"
  git -C "$DIR/prod" init -q
  git -C "$DIR/prod" config user.name test
  git -C "$DIR/prod" config user.email test@example.invalid
  git -C "$DIR/prod" config commit.gpgsign false
  echo base >"$DIR/prod/README"
  git -C "$DIR/prod" add README
  git -C "$DIR/prod" commit -q -m base
  : >"$STUB_LOG"
}
run() { # run <env...>; prints the exit status
  (cd "$DIR/prod" && env STAGING_DIR="$DIR/staging" PRODUCTION_REGISTRY=registry.suse.com/rancher/catalog \
    REPORT_FILE="$DIR/report" RESULT_FILE="$DIR/result" "$@" "$SCRIPT" >"$DIR/out" 2>"$DIR/err") && echo 0 || echo 1
}
commits() { git -C "$DIR/prod" rev-list --count HEAD; }
LOG_REL() { grep -c '^release ' "$STUB_LOG" || true; }

fresh
check "a real run succeeds" "0" "$(run STUB_MODE=ok)"
check "  two commits are made (versions, then archives and index)" "3" "$(commits)"
check "  the result says status 0 and 2 commits" "status=0 commits=2" "$(tr '\n' ' ' <"$DIR/result" | sed 's/ $//')"
check "  the first commit has the entries and the logo" "assets/logos/fleet.png entries/fleet/111.0.1+up0.17.0.yaml" "$(git -C "$DIR/prod" show --name-only --format= HEAD~1 | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')"
check "  the second has the archive and the index" "assets/fleet/fleet-111.0.1+up0.17.0.tgz index.yaml" "$(git -C "$DIR/prod" show --name-only --format= HEAD | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')"
check "  the index is made against the production registry" "1" "$(grep -c '^index --repo \. --registry registry.suse.com/rancher/catalog' "$STUB_LOG")"
check "  and without the staging credentials" "1" "$(grep -c "staging user='' pass=''" "$STUB_LOG")"

fresh
check "the staging credentials are not given to the index even when set" "0" "$(run STUB_MODE=ok CARGUEIRO_USERNAME=u CARGUEIRO_PASSWORD=secret)"
check "  (stand-in saw none)" "1" "$(grep -c "staging user='' pass=''" "$STUB_LOG")"

fresh
check "a dry run succeeds" "0" "$(run STUB_MODE=ok DRY_RUN=true)"
check "  and makes no commit" "1" "$(commits)"
check "  and writes no file" "0" "$(git -C "$DIR/prod" status --porcelain | wc -l)"
check "  and release got --dry-run" "1" "$(grep -c '^release .*--dry-run' "$STUB_LOG")"
check "  and the index was not run" "0" "$(grep -c '^index' "$STUB_LOG")"
check "  the result says 0 commits" "status=0 commits=0" "$(tr '\n' ' ' <"$DIR/result" | sed 's/ $//')"

fresh
check "a real run does not pass --dry-run" "0" "$(run STUB_MODE=ok)"
check "  release got no --dry-run" "0" "$(grep -c '^release .*--dry-run' "$STUB_LOG")"

fresh
check "a failed version still makes the commits of what went through" "0" "$(run STUB_MODE=partial)"
check "  with the status of release kept" "status=1 commits=2" "$(tr '\n' ' ' <"$DIR/result" | sed 's/ $//')"

fresh
check "nothing to release makes no commit" "0" "$(run STUB_MODE=none)"
check "  the result says 0 commits" "status=0 commits=0" "$(tr '\n' ' ' <"$DIR/result" | sed 's/ $//')"
check "  and the index was not run" "0" "$(grep -c '^index' "$STUB_LOG")"

fresh
check "a family is passed on" "0" "$(run STUB_MODE=ok FAMILY=fleet)"
check "  to release" "1" "$(grep -c '^release .*--family fleet' "$STUB_LOG")"
check "  and named in the commit" "release: the new versions of fleet from staging" "$(git -C "$DIR/prod" log -2 --format=%s | tail -1)"

fresh
for bad in "Fleet" "../fleet" "fleet;ls" "-x" "a b"; do
  check "the family '$bad' is refused" "1" "$(run STUB_MODE=ok "FAMILY=$bad")"
done
check "  and release was never called" "0" "$(LOG_REL)"
check "a DRY_RUN that is not true or false is refused" "1" "$(run STUB_MODE=ok DRY_RUN=yes)"
check "a missing STAGING_DIR is refused" "1" "$(run STUB_MODE=ok STAGING_DIR=/nonexistent)"
for bad in "" "https://registry.suse.com/rancher/catalog" "registry.suse.com" "registry.suse.com/rancher catalog"; do
  check "the production registry '$bad' is refused" "1" "$(run STUB_MODE=ok "PRODUCTION_REGISTRY=$bad")"
done
check "  and nothing was released" "0" "$(LOG_REL)"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
