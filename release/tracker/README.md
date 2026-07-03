# Release Tracking CLI

TypeScript CLI for managing release tracking tables in GitHub issues. Parses HTML table structure with data attributes, supports add/remove/update operations via comment-driven workflow.

## Security Mitigation

### CVE/Supply Chain Defense

1. **Minimal dependencies** - Only `cheerio` (stable, widely-used)
2. **Lock file committed** - `package-lock.json` pins exact versions
3. **Audit regularly**:
   ```bash
   npm audit
   npm audit fix
   ```
4. **Renovate with human gate** - Auto-PR for updates, manual merge only
5. **Subresource Integrity** - GHA uses `actions/setup-node@v4` with hash pinning
6. **No runtime execution** - Pure HTML parsing, no `eval()`, no dynamic imports

### Dependency Policy

**Allowed:**
- `cheerio` - HTML parser (required)
- `typescript`, `tsx`, `@types/node` - dev only, not in production

**Blocked:**
- Any package with critical CVEs
- Packages with <1M weekly downloads
- Packages abandoned >1 year

### Update Strategy

```bash
# Check for vulnerabilities
npm audit

# Update only patch versions (safe)
npm update

# Major/minor updates require testing
npm outdated
npm install cheerio@latest  # test locally first
```

### GHA Security

```yaml
# Pin action versions with SHA
- uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8  # v4.0.2

# Run in restricted mode
permissions:
  contents: read
  issues: write
```

## Commands

- `add-chart <chart> <version> <owner>` - Add chart row to tracking table
- `remove-chart <chart> <version>` - Remove chart from tracking table
- `update-qa <chart> <version>` - Mark QA sign-off complete
- `update-unrc <chart> <version>` - Mark Un-RC complete
- `mark-released <chart> <version>` - Mark chart released

## Local Testing

```bash
# Install deps
npm install

# Run unit tests
npm test

# Manual testing
npm run dev add-chart longhorn 109.3.1 @nick
npm run dev update-qa longhorn 109.3.1
npm run dev remove-chart longhorn 109.3.1
```

Local mode reads from `test/output.md` (if exists) or `test/fixtures/issue-body.md`, writes to `test/output.md`.

## Production Use (GHA)

Stdin/stdout mode automatically detected when piped:

```bash
BODY=$(gh issue view $ISSUE --json body -q .body)
UPDATED=$(echo "$BODY" | npm run dev update-qa fleet 110.0.0)
gh issue edit $ISSUE --body "$UPDATED"
```
