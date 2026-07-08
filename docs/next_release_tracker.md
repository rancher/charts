# Next Release Tracker Workflow

**Location:** `.github/workflows/next-release-tracker.yaml`
**Trigger:** Manual dispatch (workflow_dispatch)
**Purpose:** Initialize new release cycle with YAML files and GitHub issues

Creates release tracking infrastructure for new monthly release cycle. Deletes old release files, generates new YAML files from template, creates parent coordination issue and sub-issues for per-version tracking.

---

## When to Use

Run at start of each monthly release cycle (typically first week of month) after determining which versions to release.

---

## How to Trigger

**GitHub UI:**
1. Navigate to Actions tab
2. Select "Next Release Tracker" workflow
3. Click "Run workflow"
4. Fill inputs:
   - **versions:** `2.14.4;2.13.9;2.12.14;2.11.17` (semicolon-separated)
   - **month:** `June`
   - **year:** `2026`
5. Click "Run workflow"

---

## Inputs

**Validation:**
- All inputs must be non-empty
- Versions must match `X.Y.Z` pattern
- At least one version required

---

## What It Creates

### 1. Release YAML Files

**Location:** `release/`

**Action:**
- Deletes all existing `release/*.yaml` files (if any)
- Creates new file per version from `templates/release-versions.yaml`

**Example:**
```
release/
  2.14.4.yaml
  2.13.9.yaml
```

Each file contains all 50 charts with `"<version>"` placeholder and default false flags.

### 2. Parent GitHub Issue

**Title:** `[charts] Release June 2026`

**Body:** From `templates/charts-release-issue.md`
- Task checklist for release coordination
- Bullet list of versions being released
- Links to task info

**Label:** `release-tracking`

### 3. Sub-Issues (per version)

**Title:** Version number only (e.g., `2.14.4`)

**Body:** From `templates/charts-release-subissue.md`
- Link to parent issue
- Empty HTML table with columns: Chart, Version, Team, Chart Owner, QA, UnRC, Released
- Warning: DO NOT EDIT THIS ISSUE

**Label:** `release-tracking`

---

## Workflow Jobs

### Job 1: create-releases

1. Validate inputs
2. Checkout automation-core branch
3. Delete old release YAML files (if exist)
4. Create new release YAML files
5. Commit and push

### Job 2: create-issues

1. Checkout automation-core branch
2. Create parent issue
3. Create sub-issue for each version
4. Validate all issues created successfully

---


## Verification

After workflow completes:

**Expected:**
- `release/2.14.4.yaml` exists with 50 charts
- Parent issue exists with correct title
- One sub-issue per version with empty tables

---

## Related Documentation

- [Chart Families](chart_families.md) - Source for template generation
- [Release Versions Template](release_versions_template.md) - Template structure
