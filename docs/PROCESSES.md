# Automation-Core Processes

Quick reference for `make` targets in automation-core.

| Process | What | Why | Verify |
|---------|------|-----|--------|
| **update-dependencies** | Updates SUSE package versions and checksums in `.github/actions/dependencies/action.yaml`<br><br>See [dependencies_version.md](dependencies_version.md) | SUSE rebuilds packages periodically (security patches, compiler updates), changing checksums even when versions stay the same | Run `make test-dependencies` and ensure it succeeds |
| **test-dependencies** | Tests the dependencies action locally using `act` (Docker-based GitHub Actions runner)<br><br>See [dependencies_version.md](dependencies_version.md) | Validates dependency installation works before pushing changes to CI | N/A |
| **propagate** | Propagates automation-core infrastructure to active dev-v* and release-v* branches via Docker containers. Creates PRs for each branch and a meta-PR tracking all changes.<br><br>Workflows: [centralized_workflows.md](centralized_workflows.md)<br>Architecture: [propagate_architecture.md](propagate_architecture.md) | Keeps all branches synchronized with latest automation infrastructure without manual syncing | Manually inspect PRs (based on propagate.yaml) for:<br>• Latest changes from automation-core (`.github/workflows`, `scripts/`, `Makefile`, `.gitignore`)<br>• Branch placeholders substituted (e.g., `fossa.yml`, `auto-bump-manual-trigger.yaml`)<br>• All CIs pass on all PRs |
| **reset-propagate** | Cleans up Docker containers, images, and temporary files created during propagation<br><br>See [propagate_architecture.md](propagate_architecture.md) | Frees disk space and resets propagation environment for fresh runs | N/A |

---

## End-to-End Propagation Flow

Complete workflow for propagating infrastructure changes to all active branches:

```
automation-core branch
  ↓
make update-dependencies
  ↓
Verify: make test-dependencies
  ↓
git stage/commit/push
  ↓
Open PR against [automation-core]
  ↓
Review & merge PR
  ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ↓
make propagate
  ↓
Creates propagation PRs (per branch in propagate.yaml)
  +
Creates meta-PR (tracks all propagation PRs)
  ↓
Verify each propagation PR:
  • Latest changes present
  • Placeholders substituted
  • All CIs pass
  ↓
Review & merge propagation PRs
  ↓
Review & merge meta-PR
  ↓
make reset-propagate (optional cleanup)
```

---

## Renovate Update Flow

When Renovate merges GitHub Actions updates, propagate changes to all branches:

```
Renovate creates PR
  ↓
CI validates
  ↓
Manual review & merge
  ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ↓
Trigger End-to-End Propagation Flow
  (see above - starting from "make propagate")
```

**Why propagate:** Renovate updates workflows at automation-core. These workflows must be propagated to active branches. Composite actions are automatically propagated since workflows import them via `@automation-core` references.

**Details:** See [renovate.md](renovate.md) for configuration rationale.
