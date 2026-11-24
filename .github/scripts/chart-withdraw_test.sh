#!/usr/bin/env bash
# Tests chart-withdraw.sh with a stand-in for cargueiro that answers like the real
# one does for a family (main chart first, the same for any chart of the family),
# in a checkout that is made here.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/chart-withdraw.sh"
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
mkdir "$DIR/bin" "$DIR/repo"

cat >"$DIR/bin/cargueiro" <<'STUB'
#!/usr/bin/env bash
# Stand-in: only the calls the script makes.
echo "$*" >>"$STUB_LOG"
[ -z "${STUB_FAIL:-}" ] || { echo "error: stub failure" >&2; exit 1; }
case "$1" in
  withdraw)
    dry=false
    [ "$2" = "--family" ] || { echo "stub: withdraw without --family" >&2; exit 2; }
    [ "$3" != "--dry-run" ] || { dry=true; shift; }
    path=$3
    chart=$(basename "$(dirname "$path")")
    version=$(basename "$path" .yaml)
    case "$chart" in
      fleet | fleet-agent | fleet-crd) members="fleet fleet-agent fleet-crd" ;;
      rancher-monitoring | rancher-monitoring-crd) members="rancher-monitoring rancher-monitoring-crd" ;;
      *) members=$chart ;;
    esac
    for m in $members; do
      echo "withdraw $m $version"
      [ "$dry" = true ] || echo "withdrawn: true" >>"entries/$m/$version.yaml"
    done
    ;;
  index) ;;
esac
STUB
chmod +x "$DIR/bin/cargueiro"
export PATH="$DIR/bin:$PATH"
export STUB_LOG="$DIR/log"

cd "$DIR/repo"
for e in fleet/111.0.1+up0.17.0 fleet-agent/111.0.1+up0.17.0 fleet-crd/111.0.1+up0.17.0 \
  rancher-monitoring/111.0.0+up80.9.1-rancher.25 rancher-monitoring-crd/111.0.0+up80.9.1-rancher.25 \
  rancher-turtles/111.0.0+up0.28.0; do
  mkdir -p "entries/$(dirname "$e")"
  echo "version: $(basename "$e")" >"entries/$e.yaml"
done

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
written() { grep -rl "withdrawn: true" entries | sed 's|entries/||; s|\.yaml$||' | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//'; }
reset() {
  : >"$STUB_LOG"
  grep -rl "withdrawn: true" entries 2>/dev/null | while IFS= read -r f; do sed -i '/^withdrawn: true$/d' "$f"; done
  return 0
}
run() { # run <chart> <family> <version> [extra env...]; prints exit status
  reset
  if env CHART="$1" FAMILY="$2" VERSION="$3" "${@:4}" "$SCRIPT" >"$DIR/out" 2>"$DIR/err"; then echo 0; else echo 1; fi
}
V=111.0.1+up0.17.0

check "a chart that has no family is withdrawn" "0" "$(run rancher-turtles "" 111.0.0+up0.28.0)"
check "  only that entry is written" "rancher-turtles/111.0.0+up0.28.0" "$(written)"
check "  the index is checked and then run" "2" "$(grep -c '^index --repo' "$STUB_LOG")"

check "a chart that belongs to a family is refused as a chart" "1" "$(run fleet-crd "" $V)"
check "  nothing is written" "" "$(written)"
check "  and the message says to use the family" "1" "$(grep -c 'withdraw the family' "$DIR/err")"
check "the main chart of a family is refused as a chart too" "1" "$(run rancher-monitoring "" 111.0.0+up80.9.1-rancher.25)"
check "  nothing is written" "" "$(written)"

check "a family is withdrawn" "0" "$(run "" fleet $V)"
check "  every chart of it, the same version" "fleet-agent/$V fleet-crd/$V fleet/$V" "$(written)"
check "a family of one is withdrawn" "0" "$(run "" rancher-turtles 111.0.0+up0.28.0)"
check "  only its entry is written" "rancher-turtles/111.0.0+up0.28.0" "$(written)"
check "a chart of a family is refused as the name of the family" "1" "$(run "" fleet-crd $V)"
check "  nothing is written" "" "$(written)"
check "  and the message names the family" "1" "$(grep -c 'family of fleet-crd is fleet' "$DIR/err")"

check "a chart and a family together are refused" "1" "$(run fleet fleet $V)"
check "neither a chart nor a family is refused" "1" "$(run "" "" $V)"
check "no version is refused" "1" "$(run "" fleet "")"
for bad in "111.0.1+up0.17.0,111.0.0+up0.17.0" "111.*" "111.0.1 111.0.0" "latest" "*" "../$V" "$V;ls"; do
  check "the version '$bad' is refused" "1" "$(run "" fleet "$bad")"
done
check "  and nothing is written" "" "$(written)"
check "a name with upper case or a path is refused" "1" "$(run "" "Fleet" $V)"
check "  also with a slash" "1" "$(run "" "../fleet" $V)"
check "a version that has no entry is refused" "1" "$(run "" fleet 999.0.0+up1.0.0)"
check "  and withdraw is never called" "0" "$(grep -c . "$STUB_LOG" || true)"

check "a dry run does every check and writes nothing" "0" "$(run "" fleet $V DRY_RUN=true)"
check "  nothing is written" "" "$(written)"
check "  but a refusal is a refusal" "1" "$(run fleet-crd "" $V DRY_RUN=true)"
check "a failure of cargueiro stops it" "1" "$(run "" fleet $V STUB_FAIL=1)"
check "  and nothing is written" "" "$(written)"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
