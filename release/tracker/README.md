# Release Tracking CLI (V2)

TypeScript CLI for automating Rancher chart releases across minor versions (2.14, 2.13, 2.12, 2.11). Compares dev vs release branches, generates YAML tracking files, handles complex version formats with RC/prerelease markers.

## Security Mitigation

### CVE/Supply Chain Defense

1. **Minimal dependencies** - Only `js-yaml` (66M+ weekly downloads, stable)
2. **Lock file committed** - `package-lock.json` pins exact versions + checksums
3. **Audit regularly**:
   ```bash
   npm audit
   npm audit fix  # patch only
   ```
4. **Renovate with human gate** - Auto-PR for updates, manual merge required
5. **GHA action pinning** - Use SHA hashes not tags (`actions/setup-node@<sha>`)
6. **No code execution** - Pure YAML parsing, git operations via spawn
7. **Restricted permissions**:
   ```yaml
   permissions:
     contents: read
     issues: write
   ```

### Dependency Policy

**Allowed:**
- `js-yaml` - YAML parser (required for release.yaml / index.yaml)
- `typescript`, `tsx`, `@types/node` - dev dependencies only

**Blocked:**
- Packages with critical CVEs
- Packages <1M weekly downloads (low trust)
- Abandoned packages (>1 year no updates)

**Update Strategy:**
- Patch updates: Auto-apply after audit passes
- Minor updates: Test locally, review changelog
- Major updates: Thorough testing, assess breaking changes

## Architecture

```
src/
├── cli.ts               # CLI entry point
├── commands/            # Business logic (populate-release-charts)
├── domain/              # Pure domain functions (chart comparison logic)
├── adapters/            # External integrations (git, yaml, versions)
└── utils/               # Shared utilities
```

### Dependency Rules (Prevent Circular Imports)

| Layer         | Can Import                        | Cannot Import            |
|-------        |-----------                        |---------------           |
| **cli.ts**    | commands, domain, adapters, utils | -                        |
| **commands/** | domain, adapters, utils           | cli.ts                   |
| **domain/**   | adapters, utils                   | cli.ts, commands         |
| **adapters/** | utils                             | cli.ts, commands, domain |
| **utils/**    | -                                 | All other layers         |

**Why:** Bottom-up dependency flow. utils = pure (no deps). adapters = external integrations. domain = business logic. commands = orchestration. cli = entry point.

## Commands

### `populate-release-charts`

Populate release YAML with chart versions from dev branch.

**Usage:**
```bash
npx tsx src/cli.ts populate-release-charts <version> <yaml-path> <dev-branch> <release-branch>

# Example
npx tsx src/cli.ts populate-release-charts 2.14.4 release/2.14.4.yaml dev-v2.14 release-v2.14
```

**What it does:**
1. Reads `release.yaml` from dev branch (source of truth for "what to release")
2. Reads `index.yaml` from release and dev branch (what's already shipped vs what is present)
3. Compares versions, finds new charts (stable + highest RC per base)
4. Populates tracking YAML with chart@version entries

**RC Handling:**
- Stable version in dev not in release → add it
- Only RCs for base version → pick highest RC
- Base version = before `+up` metadata (e.g., `109.0.2` from `109.0.2+up0.15.7-rc.17`)

### `sync-table` (TODO)

Sync tracking YAML state to GitHub issue table (future feature).

## Local Development

```bash
# Install deps
npm install

# Run all tests
npm test

# Run unit tests only
npm run test:unit

# Test populate command
npx tsx src/cli.ts populate-release-charts 2.14.4 release/2.14.4.yaml dev-v2.14 release-v2.14
```

## Testing

- **Unit tests:** `test/unit/` - domain functions, adapters
- **Integration tests:** `test/integration/` - full workflows (TODO)
- Node.js built-in test runner (`node:test`)

