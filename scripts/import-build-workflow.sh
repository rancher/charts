#!/bin/bash
set -e

echo "================================================================="
echo "Import Build Workflow from automation-core"
echo "================================================================="
echo ""

# Configuration
REMOTE="upstream"
AUTOMATION_BRANCH="automation-core"
SOURCE_FILE=".github/workflows/build-core.yaml"
TARGET_FILE=".github/workflows/build.yaml"

# Validate we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "ERROR: Not in a git repository"
  exit 1
fi

# Check if target file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "WARNING: $TARGET_FILE does not exist"
  echo "It will be created"
fi

# Fetch latest automation-core
echo "Fetching latest $AUTOMATION_BRANCH from $REMOTE..."
git fetch "$REMOTE" "$AUTOMATION_BRANCH"

# Extract build-core.yaml from automation-core
echo "Extracting $SOURCE_FILE from $REMOTE/$AUTOMATION_BRANCH..."
git show "$REMOTE/$AUTOMATION_BRANCH:$SOURCE_FILE" > "$TARGET_FILE"

echo ""
echo "================================================================="
echo "✓ Import completed successfully"
echo "================================================================="
echo ""
echo "Changes:"
echo "  Imported: $SOURCE_FILE"
echo "  To:       $TARGET_FILE"
echo ""
echo "Next steps:"
echo "  Review changes:  git diff $TARGET_FILE"
echo "  Stage changes:   git add $TARGET_FILE"
echo "  Commit:          git commit -m 'feat(ci): update build workflow from automation-core'"
echo ""
