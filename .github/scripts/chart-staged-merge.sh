#!/usr/bin/env bash
# Waits for the Audit check of a pull request, and merges the pull request when
# it passes: approves it with the App behind APPROVE_TOKEN, which is not the one
# that opened it, and squash-merges it at the commit that was audited. When Audit
# fails or does not finish in time, it merges nothing and fails, so the pull
# request stays open.
#
# Environment:
#   PR_URL         the pull request, as a URL or a number
#   PR_TITLE       the title of the squash commit
#   HEAD_SHA       the commit that the pull request must be at: if anyone pushed
#                  another one, nothing is merged
#   GH_TOKEN       reads the pull request
#   APPROVE_TOKEN  approves and merges it
#   TIMEOUT        optional: seconds to wait for Audit, 1800 by default
#   INTERVAL       optional: seconds between two reads, 20 by default
#
# Requires gh and jq on PATH.
set -euo pipefail

fail() {
  echo "::error::$1" >&2
  exit 1
}

for name in PR_URL PR_TITLE HEAD_SHA GH_TOKEN APPROVE_TOKEN; do
  [ -n "${!name:-}" ] || fail "$name is missing"
done
TIMEOUT=${TIMEOUT:-1800}
INTERVAL=${INTERVAL:-20}
check=Audit

# audit_state prints the state of the Audit check: pass, fail, cancel, skipping
# or pending. A check that is not there yet is pending.
audit_state() {
  local checks
  # gh exits with 8 while a check is pending, and with 1 when there are none yet.
  checks=$(gh pr checks "$PR_URL" --json name,bucket 2>/dev/null || true)
  jq -r --arg name "$check" '(map(select(.name == $name)) | .[0].bucket) // "pending"' <<<"${checks:-[]}"
}

deadline=$((SECONDS + TIMEOUT))
while true; do
  state=$(audit_state)
  echo "$check: $state"
  case "$state" in
    pass) break ;;
    pending) ;;
    *) fail "$check is $state on $PR_URL, so it was not merged" ;;
  esac
  [ "$SECONDS" -lt "$deadline" ] || fail "$check did not finish in ${TIMEOUT}s on $PR_URL, so it was not merged"
  sleep "$INTERVAL"
done

# Only the commit that was audited is merged.
head=$(gh pr view "$PR_URL" --json headRefOid --jq .headRefOid)
[ "$head" = "$HEAD_SHA" ] || fail "$PR_URL is at $head, but $HEAD_SHA was audited, so it was not merged"

export GH_TOKEN=$APPROVE_TOKEN
gh pr review "$PR_URL" --approve --body "Auto-approving: the pull request was opened by chart-staged and $check passed."

# GitHub works out whether the pull request can be merged after the review, so a
# refusal right away is tried again.
for attempt in 1 2 3 4 5; do
  if gh pr merge "$PR_URL" --squash --subject "$PR_TITLE" --match-head-commit "$HEAD_SHA"; then
    echo "Merged $PR_URL"
    exit 0
  fi
  echo "Merge attempt $attempt failed, trying again in ${INTERVAL}s"
  sleep "$INTERVAL"
done
fail "$PR_URL passed $check and was approved, but it could not be merged"
