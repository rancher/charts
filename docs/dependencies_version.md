# Dependency Checksum Management - Business Rules

## How Checksum Verification Works

Active release branches (dev-v2.14, release-v2.13, etc.) use `.github/actions/dependencies/action.yaml` in their CI workflows to install pinned dependencies with checksum verification.

**Verification flow:**
1. CI workflow calls dependencies action
2. Action installs package with pinned version (e.g., `git-2.51.0-150600.3.15.1.x86_64`)
3. Calculates actual checksum: `sha256sum /usr/bin/git`
4. Compares against expected checksum in action.yaml
5. **If mismatch:** Calls `verify-checksum` script which triggers `repository_dispatch` event
6. **If match:** Continues CI execution

The `repository_dispatch` event with type `checksum_mismatch` triggers `.github/workflows/update-dependencies.yaml` on the same branch where the mismatch was detected.

**Fork vs Upstream PRs:**
- **Fork PR:** Opened from `contributor:branch` → lacks `github_token` input (GitHub security model)
- **Upstream PR:** Opened from `rancher:dev-v2.14` → has `github_token` via secrets/vault

## Trigger Scenarios and Resolution

| Trigger Scenario | Auto-Fix | Resolution | Auto-merge | Rationale |
|-----------------|----------|------------|------------|-----------|
| **Fork PR** (repository_dispatch) | No - fork lacks `github_token` | Cannot trigger auto-fix (lacks github_token to call GitHub API); CI fails with checksum mismatch showing helpful summary; contributor waits for scheduled run (every 6 hours) | N/A | Cannot call GitHub API to send repository_dispatch event |
| **Upstream PR** (repository_dispatch) | Yes - has `github_token` | Creates dependency PR automatically; original PR blocked until merged | Yes | Unblocks original PR quickly; CI validates changes; easy to revert if needed |
| **Scheduled Run** (cron: every 6 hours) | Yes - runs with workflow permissions | Creates PR if changes detected, exits cleanly if no changes | Yes | Proactive maintenance; CI validates changes; can be reverted if needed |
| **Manual Trigger** (workflow_dispatch) | Yes - maintainer permissions | Creates PR | No | Maintainer decides per-case; manual trigger implies exceptional circumstances |

## Auto-merge Strategy

Dependencies are stable build tools (git, docker, make, go, gh, yq, jq, patch, gawk) used to execute scripts and workflows, not application runtime dependencies.

**Why auto-merge:**
- CI validates all changes work correctly
- Breaking changes are rare and caught by CI
- Easy to revert if issues detected
- Eliminates manual toil for predictable SUSE package rebuilds
- Unblocks PRs quickly (especially critical during release windows)

**Trust model:** CI is the validation gate. If CI passes, changes are safe. Manual review adds no value beyond what CI already validates.
