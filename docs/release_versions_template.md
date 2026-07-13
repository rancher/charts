# Release Versions Template

**Location:** `templates/release-versions.yaml`
**Generated from:** `config/chart-families.yaml`
**Purpose:** Template for creating release tracking files

Template containing all charts with placeholder version strings and default status values. Used by release tracking GHAs to create monthly release files.

---

## Structure

```yaml
elemental:
  "<version>":      # Placeholder replaced by GHA
    QA: false       # QA sign-off complete
    UnRC: false     # Un-RC complete
    Released: false # Merged to release branch
```

- One entry per chart (50 total)
- `"<version>"` placeholder replaced with real version
- All defaults: `false`

---

### Automatic Generation

When `config/chart-families.yaml` changes in PR to automation-core:
1. `sync-release-versions-template.yaml` GHA triggers
2. Runs `make release-versions-template`
3. Commits updated template to PR

### Manual Generation

```bash
make release-versions-template
```

---

## Maintenance

**DO NOT edit manually** - template is auto-generated.

To change structure:
1. Update `config/chart-families.yaml`
2. PR triggers auto-regeneration

To change format:
1. Edit `release/scripts/generate-release-versions-template`
2. Update `FILE_HEADER` or `CHART_ENTRY_TEMPLATE` constants

---

## Related Documentation

- [Chart Families](chart_families.md) - Source config
- [PROCESSES.md](PROCESSES.md) - All automation operations
