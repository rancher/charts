# Release Tracker System

GitHub-native monthly release tracking via HTML tables in issues, updated by comment-driven automation.

---

## Architecture Flow

### Production Flow (GitHub Actions)

```mermaid
sequenceDiagram
    participant User
    participant Issue as GitHub Issue
    participant GHA as GitHub Actions
    participant CLI as TypeScript CLI
    participant File as test/output.md

    User->>Issue: Post comment<br/>"ToRelease: fleet 1.0.0"
    Issue->>GHA: Trigger workflow<br/>(issue_comment event)

    GHA->>GHA: Checkout automation-core branch
    GHA->>GHA: Setup Node.js 20
    GHA->>GHA: cd release/tracker && npm ci

    GHA->>Issue: Read issue body<br/>(gh issue view --json body)
    GHA->>CLI: Pipe stdin | npx tsx src/index.ts add-chart fleet 1.0.0

    CLI->>CLI: Parse HTML table
    CLI->>CLI: Add chart row
    CLI->>File: Write updated HTML

    GHA->>File: Read test/output.md
    GHA->>Issue: Update issue body<br/>(gh issue edit --body)
    GHA->>Issue: Quote reply to comment<br/>(gh issue comment --body)
```

### Development Flow (Local Testing)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Fixture as test/fixtures/issue-body.md
    participant CLI as TypeScript CLI
    participant Output as test/output.md

    Dev->>Fixture: cat test/fixtures/issue-body.md
    Fixture->>CLI: Pipe stdin | npx tsx src/index.ts add-chart fleet 1.0.0

    CLI->>CLI: Parse HTML table
    CLI->>CLI: Add chart row
    CLI->>Output: Write updated HTML

    Dev->>Output: cat test/output.md<br/>(verify changes)
```

---

## Data Flow

```mermaid
graph LR
    A[Issue Body HTML] -->|stdin| B[CLI src/index.ts]
    B --> C[runCommand]
    C --> D{Switch on Command}

    D --> E[Command Handler<br/>add-chart, update-qa, etc]

    E --> F[Updated HTML]

    F -->|write| G[test/output.md]
```

---

## File Structure

```
release/tracker/
├── src/
│   ├── index.ts              # CLI entry point (stdin → test/output.md)
│   ├── parser.ts             # Cheerio HTML utilities
│   └── commands/             # Command implementations (add-chart, update-qa, etc)
│                             # errors.ts, validation.ts
├── test/
│   ├── fixtures/             # Static test input files
│   ├── unit/                 # Unit tests per command
│   ├── integration/          # Full workflow tests
│   └── output.md             # Generated output (gitignored)
├── package.json
└── tsconfig.json
```

---

## Key Design Decisions

### Why test/output.md (not stdout)?

**Problem:** console.log debug statements pollute stdout
**Solution:** Write to file, logs go to GHA console

**Benefits:**
- Debug logs visible in GHA runs
- Same path in dev and production
- Easy to inspect on failure
- Matches test infrastructure

### Why stdin (not --input flag)?

**Reason:** GitHub CLI outputs JSON to stdout
**Usage:** `gh issue view 123 --json body -q .body | npx tsx ...`

### Why HTML table (not markdown)?

**Reason:** Data attributes enable machine parsing
**Example:**
```html
<tr data-chart="fleet" data-version="1.0.0" data-qa="true">
  <td class="chart">fleet</td>
  <td class="qa">yes</td>
</tr>
```

Cheerio can find rows via `$('tr[data-chart="fleet"][data-version="1.0.0"]')`

---

## Error Handling

### Centralized Error Messages (errors.ts)

All errors are **user-facing** (displayed in GHA comment replies), not developer debug output.

**Architecture:** Factory functions in `src/commands/errors.ts`

```typescript
export const Errors = {
  chartNotFound: (chart: string, version: string) => `Chart "${chart}" version "${version}" is not in the release table.

Check the chart name and version are correct.
If you made a typo in your comment, please post a new comment with the correct values.`,

  tableNotFound: () => `Could not find release tracking table.
This issue may not be set up correctly.

Please contact @rancher/release-team`,
};
```

**Why this approach:**

1. **User-facing by design:** Errors explain what happened + how to fix, no technical jargon
2. **Consistency:** All commands share error messages (e.g., `tableNotFound` used by all)
3. **Maintainability:** Single place to update wording, affects all commands
4. **Testability:** Tests import `Errors.chartNotFound('x', '1.0')` and validate exact message
5. **Type-safe params:** `chartNotFound(chart: string, version: string)` prevents missing values

**Example:**
```typescript
// Command code
if (row.length === 0) {
  throw new Error(Errors.chartNotFound(options.chart, options.version));
}

// Test code
assert.strictEqual(err.message, Errors.chartNotFound('fleet', '1.0.0'));
```

