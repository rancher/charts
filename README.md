# automation-core

Single source of truth for automation infrastructure across all rancher/charts branches.

## What is automation-core?

The `automation-core` branch centralizes all automation infrastructure (workflows, scripts, actions, Makefile) for the rancher/charts repository. Active branches (dev-v2.15, release-v2.14, etc.) consume this infrastructure instead of maintaining their own copies.

## Why does it exist?

**Problem:** Rancher/charts has 12+ active branches that previously each maintained duplicate automation code. Updating workflows or scripts required manual forward-porting to every branch — high maintenance overhead and risk of divergence.

**Solution:** Centralize infrastructure in automation-core. Active branches pull/reference from here. One update propagates to all branches automatically.

## What does it contain?

| Component | How it's consumed |
|-----------|------------------|
| **Workflows** (`.github/workflows/`) | Templates with placeholders, propagated to branches |
| **Composite Actions** (`.github/actions/`) | Live references via `@automation-core` |
| **Scripts** (`scripts/`) | Pulled on-demand via `make pull-scripts` |
| **Makefile** | Pulled on-demand via `make pull-scripts` |
| **Propagation System** (`scripts/automation/`) | Docker-based sync to active branches |

## How to use it

See **[docs/PROCESSES.md](docs/PROCESSES.md)** for all operations (`make update-dependencies`, `make propagate`, etc.)

## Structure

```
.github/
├── workflows/          # Workflow templates (build, auto-bump, fossa, registry ops)
├── actions/            # Composite actions (dependencies, build validation)
└── renovate.json       # Automated dependency updates

scripts/
├── automation/         # Propagation system (Docker-based sync)
├── release-validation/ # Release validation scripts
└── pull-scripts        # Bootstrap: pull scripts/Makefile from automation-core

Makefile                # Automation targets (update-dependencies, propagate, etc.)
```

## Documentation

- **[PROCESSES.md](docs/PROCESSES.md)** - Start here: all make targets and workflows
- **[propagate_architecture.md](docs/propagate_architecture.md)** - How propagation works
- **[development.md](docs/development.md)** - Local testing with act
