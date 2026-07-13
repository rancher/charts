# Start Release Tracker Workflow

**Location:** `.github/workflows/start-release-tracking.yaml`
**Trigger:** Manual dispatch (workflow_dispatch)
**Purpose:** Initialize new release cycle with populated YAML files and GitHub issues

Creates release tracking infrastructure for new monthly release cycle. Generates new YAML files from template, populates them with chart versions from dev/release branches, creates PR to automation-core, and creates parent coordination issue with sub-issues for per-version tracking.

---

## When to Use

Run at start of each monthly release cycle (typically first week of month) after determining which versions to release.

---

## How to Trigger

**GitHub UI:**
1. Navigate to Actions tab
2. Select "Start Release Tracking" workflow
3. Click "Run workflow"
4. Fill inputs:
   - **versions:** `2.14.4,2.13.9,2.12.14,2.11.17` (comma-separated)
   - **month:** `July`
   - **year:** `2026`
5. Click "Run workflow"

---

## Inputs

**Validation:**
- All inputs must be non-empty
- Versions must match `X.Y.Z` pattern (comma-separated)
- At least one version required
- Whitespace automatically normalized

---

## What It Creates

### 1. Release YAML Files (via PR)

**Location:** `release/`

**Action:**
- Creates new file per version from `templates/release-versions.yaml`
- Runs `populate-release-charts` CLI to populate chart versions from dev/release branches
- Opens PR to automation-core with populated files

**Example:**
```
release/
  2.14.4.yaml
  2.13.9.yaml
```

Each file contains all charts with actual versions populated from dev branch `release.yaml` and release branch `index.yaml`.

**IMPORTANT:** After a release cycle completes, old YAML files must be manually removed via PR. This workflow does NOT delete existing files to prevent accidental data loss.

### 2. Parent GitHub Issue

**Title:** `[charts] Release July 2026`

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

## Workflow Steps

1. Display workflow context (versions, month, year, actor)
2. Validate input format
3. Load Vault secrets for GitHub App authentication
4. Build YAML filenames
5. Checkout automation-core branch
6. Verify directory structure and check for existing files (errors if exist)
7. Create release YAML files from template
8. Setup Node.js environment
9. Install CLI dependencies
10. Populate release YAMLs with chart versions
11. Commit changes and create PR to automation-core
12. Create parent GitHub issue
13. Create sub-issues for each version

---

## Verification

After workflow completes:

**Expected:**
- PR opened against automation-core with populated `release/2.14.4.yaml` etc.
- Each YAML file contains actual chart versions (not `<version>` placeholders)
- Parent issue exists with correct title
- One sub-issue per version with empty tables

---

## End of Release Cycle

When a release cycle completes and new tracking YAMLs are created, **manually submit a PR** to remove old YAML files from `release/` directory to keep the directory clean.

---

## Related Documentation

- [Chart Families](chart_families.md) - Source for template generation
- [Release Versions Template](release_versions_template.md) - Template structure
