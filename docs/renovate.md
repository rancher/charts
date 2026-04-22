# Renovate Configuration

Custom configuration for GitHub Actions updates in automation-core.

## Key Configuration Decisions

### Ignored Paths
```json
"ignorePaths": [
  ".github/workflows/test-dependencies.yaml"
]
```

**Why:** Manual testing workflow used only in automation-core. Not propagated to active branches, so updates are irrelevant and create noise.

---

### File Matching
```json
"fileMatch": [
  "\\.github/workflows/.+\\.ya?ml$",
  "\\.github/actions/.+/action\\.ya?ml$"
]
```

**Why:** Scans both workflows and composite actions. Default Renovate config only scans workflows - we need composite actions covered too.

---

### Ignoring Internal Actions
```json
{
  "matchPackagePatterns": ["^rancher/charts$"],
  "enabled": false
}
```

**Why:** Internal composite actions reference `@automation-core` branch, not versions (e.g., `rancher/charts/.github/actions/dependencies@automation-core`). Renovate cannot update branch references, so disable to prevent noise.

**How this works with File Matching:** We scan composite actions (via fileMatch) to update external dependencies they use (e.g., `actions/checkout@v4`, `docker/login-action@v3`), but ignore internal references to our own actions (via this rule). This allows Renovate to keep external actions in our composite actions up-to-date while ignoring self-references.

---

### Grouping All Updates
```json
"groupName": "GitHub Actions",
"automerge": false
```

**Why:** Groups all GitHub Actions updates into a single PR instead of individual PRs per action. Reduces review overhead. Auto-merge disabled - requires manual review before propagation.

---

### Rate Limits
```json
"prConcurrentLimit": 2,
"prHourlyLimit": 2
```

**Why:** Prevents Renovate from flooding PRs. Conservative limits for controlled updates.

---

## After Merge

When Renovate PR is merged, trigger full propagation flow (see `PROCESSES.md` - Renovate update flow).
