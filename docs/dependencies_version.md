# Dependency Checksum Management

## Overview

CI workflows use `.github/actions/dependencies/action.yaml` to install pinned dependencies with checksum verification. All dependencies use pinned versions with verified checksums to ensure supply chain security.

**Dependencies:**
- **SUSE packages** (docker, jq, git, make, go, patch, gawk): Managed manually via `scripts/update-dependencies`
- **GitHub releases** (yq, gh): Managed automatically via Renovate

## Checksum Verification Flow

**CI execution:**
1. CI workflow calls dependencies action
2. Action installs package with pinned version (e.g., `git-2.51.0-150600.3.15.1.x86_64`)
3. Calculates actual checksum: `sha256sum /usr/bin/git`
4. Compares against expected checksum in action.yaml
5. **If mismatch:** Calls `verify-checksum` script which posts helpful summary to PR
6. **If match:** Continues CI execution

**On checksum mismatch:**
- CI check fails with detailed summary
- Summary shows package name, expected vs actual checksum
- Instructs to contact a maintainer for resolution
- **No automated fixes** - all updates require manual review

## SUSE Package Updates

SUSE periodically rebuilds packages (security patches, compiler updates). This changes the binary checksum even when the version stays the same.

**SUSE BCI package curation:**
- Packages from [SUSE Base Container Images (BCI)](https://opensource.suse.com/bci-docs/) - a curated subset of SLES
- Over 4,000 packages undergo quality assurance and security audits by SUSE
- Same CVE mitigation as SUSE Linux Enterprise Server
- SUSE controls version selection - conservative, enterprise-grade lifecycle

**Manual update process:**
1. Maintainer runs `./scripts/update-dependencies` locally
2. Script fetches latest SUSE package versions/checksums via Docker
3. Shows comparison table of current vs latest
4. Prompts for confirmation
5. Updates `action.yaml` with new versions/checksums
6. Maintainer reviews changes, commits, and creates PR

**Why manual:**
- Human security gate for supply chain attacks
- SUSE's conservative curation provides implicit stability
- Maintainer controls timing of updates
- All changes reviewed before merge

## GitHub Release Updates (yq, gh)

Renovate automatically detects and proposes updates for GitHub release packages.

**Renovate configuration:**
```yaml
# In action.yaml:
# renovate: datasource=github-releases depName=cli/cli
GH_VERSION: "v2.89.0"
# renovate: datasource=github-release-attachments depName=cli/cli digestVersion=v2.89.0
EXPECTED_CHECKSUM: "d0422caade520530e76c1c558da47daebaa8e1203d6b7ff10ad7d6faba3490d8"
```

**Update process:**
1. Renovate detects new release
2. Creates PR with version and checksum updates
3. CI validates changes
4. Maintainer reviews and merges

## Security Model

**Human review required:** All dependency updates (SUSE and GitHub releases) require manual review and approval by a maintainer before merge.

**No automation:** Removed automated workflows and auto-merge due to security vulnerabilities identified in code review. All updates flow through manual PR review process.

**Trust boundary:** CI validates that updated dependencies work correctly. Maintainer validates that updates are legitimate and not supply chain attacks.
