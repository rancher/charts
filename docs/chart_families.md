# Chart Families Configuration

**Location:** `config/chart-families.yaml`
**Purpose:** Single source of truth for chart family definitions

---

## What is a Chart Family?

A chart family is a group of charts that usually release together at the same version. Examples:

**Multi-chart family:**
```yaml
fleet:
  - fleet
  - fleet-agent
  - fleet-crd
```
All three charts release together (e.g., 110.0.0+up0.16.0).

**Single-chart family:**
```yaml
rancher-webhook:
  - rancher-webhook
```
Chart releases independently.

---

**Key points:**
- Alphabetically sorted within each section
- Family name used in release tracking
- All charts in family share same version
- Single-chart families list themselves for consistency

---

## Usage

### Who uses this file?

| Consumer | Purpose |
|----------|---------|
| **release-tracker GHAs** | Validate chart names in release YAML files |
| **generate-release-versions-template** | Generate template with all chart families |
| **next-release-tracker** | Create new release tracking files |

### When to update

Add/remove entries when:
- New chart added to repository
- Chart deprecated/removed
- Multi-chart family splits or merges

---

## Maintenance

### Adding a new chart

1. Determine if single or multi-chart family
2. Add to appropriate section (alphabetically)
3. Open PR to automation-core
4. Template auto-regenerates via GHA

**Example - new single-chart:**
```yaml
rancher-new-feature:
  - rancher-new-feature
```

**Example - new multi-chart family:**
```yaml
rancher-observability:
  - rancher-observability-ultra-pro-max
  - rancher-observability-ultra-pro-max-crd
```

---

## Validation

Chart families validated in PRs via:
- `sync-release-versions-template.yaml` GHA
- Release tracker validation workflows

No manual validation needed.

---

## Related Documentation

- [Release Versions Template](release_versions_template.md) - Generated from this config
- [PROCESSES.md](PROCESSES.md) - How to regenerate template manually
