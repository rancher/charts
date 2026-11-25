#!/usr/bin/env bash
# Prints the charts that Rancher pins and that a range of commits of the staging branch added a version of, one per
# line, without repeats. It prints nothing when there are none. Only an entry that is added counts: hiding or
# withdrawing a version changes or deletes a file, and is not a new version to pin.
#
# The list is the one of the pins that rancher/rancher-assets sets in push-to-rancher/update-pins.sh. Keep them in
# step: a chart that is in that script and not here does not start the bump.
#
# Environment:
#   AFTER   the last commit of the range
#   BEFORE  the commit before the range, normally the one that the branch was at before the push. When it is empty, all
#           zeros (the push created the branch) or not in the clone (a force push), the commit AFTER alone is looked at.
#   PINNED  optional: the chart names, separated by spaces
#
# Requires git, run in a clone with the history of both commits (the blobs are not needed).
set -euo pipefail

PINNED=${PINNED:-"fleet remotedialer-proxy rancher-turtles rancher-webhook rancher-aks-operator rancher-eks-operator rancher-gke-operator system-upgrade-controller"}

: "${AFTER:?AFTER is missing}"
before=${BEFORE:-}
if [ -z "$before" ] || [[ "$before" =~ ^0+$ ]] || ! git cat-file -e "${before}^{commit}" 2>/dev/null; then
  before="${AFTER}^"
fi

# entries/<chart>/<version>.yaml, one new file per chart version that was shipped
git diff --name-only --diff-filter=A "$before" "$AFTER" -- 'entries/*/*.yaml' | while IFS= read -r path; do
  chart=${path#entries/}
  chart=${chart%%/*}
  case " $PINNED " in
    *" $chart "*) echo "$chart" ;;
  esac
done | sort -u
