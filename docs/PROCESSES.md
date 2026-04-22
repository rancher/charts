# Automation-Core Processes

Quick reference for `make` targets in automation-core.

| Process | What | Why | Verify | Details |
|---------|------|-----|--------|---------|
| **update-dependencies** | Updates SUSE package versions and checksums in `.github/actions/dependencies/action.yaml` | SUSE rebuilds packages periodically (security patches, compiler updates), changing checksums even when versions stay the same | TBD | [dependencies_version.md](dependencies_version.md) |
| **test-dependencies** | Tests the dependencies action locally using `act` (Docker-based GitHub Actions runner) | Validates dependency installation works before pushing changes to CI | TBD | [dependencies_version.md](dependencies_version.md) |
| **propagate** | Propagates automation-core infrastructure to active dev-v* and release-v* branches via Docker containers. Creates PRs for each branch and a meta-PR tracking all changes. | Keeps all branches synchronized with latest automation infrastructure without manual syncing | TBD | Workflows: [centralized_workflows.md](centralized_workflows.md)<br>Architecture: [propagate_architecture.md](propagate_architecture.md) |
| **reset-propagate** | Cleans up Docker containers, images, and temporary files created during propagation | Frees disk space and resets propagation environment for fresh runs | TBD | [propagate_architecture.md](propagate_architecture.md) |
