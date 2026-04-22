# Propagate Architecture

Technical deep-dive into the automation-core propagation system.

## Overview

Propagation syncs automation infrastructure from `automation-core` to active branches using isolated Docker containers. Each branch gets its own container, runs sync operations, and creates a PR. A meta-PR tracks all propagation PRs.

## Architecture

```
propagate (host)
  ↓
  Reads: propagate.yaml
  ↓
  For each branch:
    ↓
    container-setup (host) → Docker container (isolated)
      ↓
      container-sync (inside container)
        ↓
        Sync operations:
          - pull-scripts
          - import-workflows
          - substitute placeholders
        ↓
        Push + create PR
  ↓
  create-meta-pr (host)
```

## Files

### propagate
**Type:** Main orchestration script (Bash)  
**Runs:** On host machine  
**Purpose:** Coordinates entire propagation process

**Flow:**
1. Validates dependencies (Docker, yq, gh, git)
2. Parses `propagate.yaml` to build branch list
3. Builds Docker image (if needed)
4. Calls `container-setup` for each branch sequentially (fail-fast)
5. Collects PR URLs from each container
6. Creates meta-PR against automation-core
7. Prompts to stop containers

**Output:** Meta-PR URL + list of all propagation PR URLs

---

### container-setup
**Type:** Container lifecycle manager (Bash, sourced by propagate)  
**Runs:** On host machine  
**Purpose:** Manages Docker container creation, startup, and sync execution

**Flow:**
1. Check if container exists (create/start as needed)
2. Extract git identity and GitHub token from host
3. Copy `container-sync` script into container
4. Execute `container-sync` inside container
5. Parse PR URL from container output
6. Return PR URL to propagate script

**Marker-based communication:** Uses `CONTAINER_SETUP_PR_URL=<url>` marker for parsing

---

### container-sync
**Type:** Branch sync script (Bash)  
**Runs:** Inside Docker container  
**Purpose:** Performs actual sync operations for a single branch

**Input:** Branch name (e.g., `dev-v2.15`)

**Flow:**
1. Checkout target branch
2. Fetch `automation-core`
3. Create propagate branch (`propagate-dev-15` or `propagate-rel-14`)
4. Sync infrastructure:
   - `sync_pull_scripts` - Update pull-scripts from automation-core
   - `run_pull_scripts` - Run pull-scripts (syncs .gitignore, Makefile)
   - `import_workflows` - Import workflow templates
   - `substitute_branch_placeholders` - Replace `{{BRANCH}}` with actual branch
5. Stage and commit changes (.gitignore, Makefile, workflows, pull-scripts)
6. Push to upstream with force
7. Create PR (or update existing if PR already open)
8. Output marker: `PROPAGATE_PR_URL=<url>`

**Isolation:** Fresh git clone, separate branch, no cross-contamination

---

### propagate.yaml
**Type:** YAML configuration  
**Purpose:** Defines which branches receive propagation

**Format:**
```yaml
dev:
  - 15  # → dev-v2.15
  - 14  # → dev-v2.14

release:
  - 15  # → release-v2.15
  - 14  # → release-v2.14
```

Branch prefixes added automatically during parsing.

---

### propagate-meta-template.md
**Type:** Markdown template  
**Purpose:** Template for meta-PR body

**Placeholders:**
- `{{BRANCH_COUNT}}` - Number of branches propagated
- `{{PR_LIST}}` - Newline-separated list of PR URLs
- `{{CBS_VERSION}}` - charts-build-scripts version
- `{{DATE}}` - Current date (YYYY-MM-DD)

---

### Dockerfile
**Type:** Docker image definition  
**Purpose:** Creates container with all dependencies pre-installed

**Base:** `registry.suse.com/bci/bci-base:latest`

**Contents:**
- Fresh clone of rancher/charts in `/repo`
- Git, GitHub CLI (gh), yq, jq
- Git credentials configured via env vars

**Build:** Only built once, reused across branches

---

### reset-propagate
**Type:** Cleanup script (Bash)  
**Purpose:** Removes containers, image, and temporary files

**Cleans:**
- All containers matching `*_propagate` pattern
- Docker image `rancher-charts-propagate:local`
- Log directory `logs/propagate`

## Branch Placeholders

Workflows and scripts use placeholders replaced during propagation:

**Placeholder:** `{{BRANCH}}`  
**Location:** `.github/workflows/*.yaml`, `.github/workflows/*.yml`  
**Replaced by:** Actual branch name (e.g., `dev-v2.15`, `release-v2.14`)  
**Function:** `substitute_branch_placeholders()` in `container-sync`

**Example:**
```yaml
# automation-core template:
on:
  push:
    branches: ["{{BRANCH}}"]

# After propagation to dev-v2.15:
on:
  push:
    branches: ["dev-v2.15"]
```

**Script configuration:** `scripts/version` contains `UPSTREAM_BRANCH` and `OLD_UPSTREAM_BRANCH` manually updated per branch during propagation.

## PR Creation

### Propagation PRs
**Base:** Target branch (e.g., `dev-v2.15`)  
**Head:** Propagate branch (e.g., `propagate-dev-15`)  
**Title:** `[dev-v2.15] infra propagation`  
**Body:** Generated from sync metadata (CBS version, date)

**Behavior:**
- If PR already exists (same head branch), force push updates it
- PR URL stored in associative array: `PR_URLS[branch]=url`

### Meta-PR
**Base:** `automation-core`  
**Head:** `propagate-batch-YYYY-MM-DD`  
**Title:** `[automation-core] propagate infra`  
**Body:** From `propagate-meta-template.md` with all PR URLs

**Purpose:** Single tracking PR for entire propagation batch

## Execution Model

**Sequential processing:** Fail-fast mode - if one branch fails, abort remaining  
**Container reuse:** Containers persist after run for inspection  
**Idempotent:** Safe to re-run - updates existing PRs instead of creating duplicates  
**Isolation:** Each branch in separate container, no shared state
