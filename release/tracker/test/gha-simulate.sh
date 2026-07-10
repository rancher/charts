#!/bin/bash
set -e

# Simulate GitHub Actions workflow for release tracking
# Usage: ./test/gha-simulate.sh <issue-number> <comment-body>

ISSUE_NUM=${1:-}
COMMENT_BODY=${2:-}

if [ -z "$ISSUE_NUM" ] || [ -z "$COMMENT_BODY" ]; then
  echo "Usage: $0 <issue-number> <comment-body>"
  echo ""
  echo "Examples:"
  echo "  $0 8056 'ToRelease: fleet 110.0.0'"
  echo "  $0 8056 'QA: fleet 110.0.0'"
  echo "  $0 8056 'UnRC: fleet 110.0.0'"
  exit 1
fi

# Simulate GHA environment vars
COMMENT_USER=$(gh api user -q .login)
COMMENT_ID="12345"  # Mock for now

echo "=== Simulating GHA Workflow ==="
echo "Issue: #$ISSUE_NUM"
echo "Comment: $COMMENT_BODY"
echo "User: $COMMENT_USER"
echo ""

# Step 1: Get issue body
echo "Step 1: Fetching issue body..."
ISSUE_BODY=$(gh issue view "$ISSUE_NUM" --json body -q .body)

if [ -z "$ISSUE_BODY" ]; then
  echo "Error: Could not fetch issue body"
  exit 1
fi

echo "✓ Fetched issue body (${#ISSUE_BODY} chars)"
echo ""

# Step 2: Run CLI
echo "Step 2: Running CLI..."
cd "$(dirname "$0")/.."

npx tsx src/cli.ts \
  --issue-num "$ISSUE_NUM" \
  --issue-body "$ISSUE_BODY" \
  --comment-body "$COMMENT_BODY" \
  --comment-user "$COMMENT_USER" \
  --comment-id "$COMMENT_ID"

if [ $? -ne 0 ]; then
  echo "✗ CLI failed"
  exit 1
fi

echo ""

# Step 3: Update issue
echo "Step 3: Updating issue..."
gh issue edit "$ISSUE_NUM" --body "$(cat test/output.md)"

if [ $? -ne 0 ]; then
  echo "✗ Failed to update issue"
  exit 1
fi

echo "Issue updated"
echo ""

# Step 4: React to comment (skip for now - mock comment ID)
echo "Step 4: Adding reaction (skipped - mock comment ID)"
echo ""

echo "Success"
echo "View issue: https://github.com/rancher/charts/issues/$ISSUE_NUM"
