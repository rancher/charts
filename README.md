# automation-core

Centralized workflows and scripts for rancher/charts release branches.

This branch contains reusable GitHub Actions workflows and composite actions that are consumed by active release branches (dev-v2.14, release-v2.13, etc.) to eliminate forward-porting maintenance overhead.

---

## Development

### Prerequisites

**act** - Run GitHub Actions workflows locally for testing before pushing to remote.

#### Installation

```bash
curl -s https://api.github.com/repos/nektos/act/releases/latest \
  | grep "browser_download_url.*Linux_x86_64.tar.gz" \
  | cut -d '"' -f 4 \
  | xargs curl -L -o /tmp/act.tar.gz

sudo tar xzf /tmp/act.tar.gz -C /usr/local/bin act
sudo chmod +x /usr/local/bin/act
```

**Verify installation:**
```bash
act --version
```

#### Configuration

On first run, act will prompt for a default runner image. Select **Micro** (<200MB).

---

### Testing Workflows Locally

#### Test dependency installation action:
```bash
act -j test-dependencies --container-architecture linux/amd64
```

This runs the workflow defined in `.github/workflows/test-dependencies.yaml` which tests the composite action at `.github/actions/dependencies/`.

#### How it works:
- `act` reads workflow YAML files from `.github/workflows/`
- Spins up Docker containers matching the workflow's `runs-on` and `container` specifications
- Executes workflow steps inside the container
- Removes containers after completion

**Note:** Workflows run in isolated containers — your host system remains unchanged.

---

### Adding New Dependencies

When adding new system dependencies to `.github/actions/dependencies/action.yaml`:

1. **Pin the version and checksum:**
   ```bash
   # Install in test container to get info
   docker run --rm registry.suse.com/bci/bci-base:latest bash -c "
     zypper --non-interactive refresh &>/dev/null
     zypper --non-interactive install <package> &>/dev/null
     sha256sum /usr/bin/<binary>
     <binary> --version
     rpm -q <package>
   "
   ```

2. **Add to action.yaml following the Docker pattern:**
   - Hardcode package version and expected checksum as variables
   - Install via zypper with pinned version
   - Verify version output
   - Calculate actual checksum
   - Compare actual vs expected checksum
   - Fail if mismatch

3. **Test locally:**
   ```bash
   act -j test-dependencies --container-architecture linux/amd64
   ```

4. **Update test workflow:**
   Add version check to `.github/workflows/test-dependencies.yaml` verification step.

---

## Structure

```
.github/
├── workflows/
│   ├── build-core.yaml              # Template for active branch build workflows
│   └── test-dependencies.yaml       # Local testing workflow
└── actions/
    └── dependencies/
        └── action.yaml              # Composite action: install dependencies with checksum verification

```

---

## References

- [act documentation](https://nektosact.com/)
- [GitHub Actions: Reusing workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows)
- [GitHub Actions: Creating composite actions](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action)
