# Centralized Workflows and Scripts Architecture

## Overview

The `automation-core` branch is the single source of truth for all automation infrastructure. Active branches (dev-v*, release-v*) pull scripts/Makefile and reference actions directly from automation-core.

**Key principle:** Active branches never maintain their own automation—they consume from automation-core.

## Architecture

| Component | automation-core | Active Branches | Distribution |
|-----------|----------------|-----------------|--------------|
| **Scripts** | Source of truth | Pulled via `make pull-scripts` | On-demand |
| **Makefile** | Source of truth | Overwritten by `make pull-scripts` | On-demand |
| **Actions** (`.github/actions/`) | Source of truth | Referenced via `@automation-core` | Live (immediate) |
| **Workflows** (`.github/workflows/`) | Templates | Imported and committed locally | Via `import-build-workflow` |
| **Binary** (`charts-build-scripts`) | N/A | Downloaded from GitHub releases | On-demand |
| **Bootstrap** (`pull-scripts`, `version`) | N/A | Local (never pulled) | Manual only |

## Distribution Flow

### Live References (Actions)

Workflows reference composite actions directly from automation-core:

```yaml
# .github/workflows/build.yaml
- uses: rancher/charts/.github/actions/dependencies@automation-core
```

**Propagation:** Immediate—changes to automation-core affect all branches instantly.

### Pull Model (Scripts/Makefile)

Run `make pull-scripts` to fetch:
- Scripts from automation-core (only if missing)
- Makefile from automation-core (always overwritten)
- Binary from GitHub releases (version pinned in `scripts/version`)

**Propagation:** Manual—run in each active branch when updates needed.

### Workflow Import

Run `./scripts/import-build-workflow` to pull workflow templates from automation-core and commit locally.

**Propagation:** Manual—import and commit to active branch.

## Dependency Chain

```
Workflow (.github/workflows/build.yaml)
  ↓
Actions (@automation-core: dependencies → build)
  ↓
make pull-scripts
  ↓
Scripts + Makefile (automation-core) + Binary (GitHub releases)
  ↓
make targets → ./scripts/* + ./bin/charts-build-scripts
```

## Security Model

**Immutable (never delete):**
- `scripts/pull-scripts` - bootstrap (cannot self-update)
- `scripts/version` - binary version pin

**Mutable (pulled from automation-core):**
- `Makefile` - overwritten every pull
- All other scripts - pulled if missing

**Rationale:** Losing `pull-scripts` breaks the distribution chain. Each branch controls its binary version via `scripts/version`.
