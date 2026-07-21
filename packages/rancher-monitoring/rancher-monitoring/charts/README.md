# ob-team-charts
A repo for Rancher Observability &amp; Backups team's charts - a canonical dev spot just before rancher/charts.

## Prerequisites

The Makefile and scripts in this repo require [`dep-fetch`](https://github.com/rancherlabs/dep-fetch) to be installed and available on your `PATH`. It is used to pull down binary dependencies (e.g. `charts-build-scripts`, `yq`, `gh`) before running chart operations.

## What ORBS projects use this repo?

This covers the following ORBS team charts:
- `rancher-monitoring`,
- `rancher-project-monitoring`, and
- `rancher-logging`

This is where we apply the majority of the Rancher specific changes to these charts.
None of the changes we apply at this level should be specific to a single Rancher minor version.

## How do we manage Chart version numbers?

Most charts should use this syntax: `{upstream version}-rancher.{incrementing number}`.  

Where each new `{upstream version}` resets the `{incrementing number}`. The result being that for any upstream version 
that we release, we will also be able to track what rancher specific changes were applied.
And that this version is universal across all Rancher minor versions that support a given `{upstream version}`.

For more specifics on why this format is used, see: [How do we manage Chart versions across this repo and `rancher/charts`?](./docs/semver-across-chart-repos.md)

The only exception is Rancher Project Monitoring uses SemVer. However, each version of Project Monitoring chart is directly dependent on a specific Rancher Monitoring.

## How are PRs merged into this repo?
PRs are merged only after they've been tested. The flow is:
1. ORBS team approves the PR
2. QA validates the changes and comments on the associated issue
3. ORBS team merges the PR

This ensures every commit on main is a "safe version" - tested and ready to release. It also lets us maintain a single branch (`main`) instead of separate dev and release branches.

Since revision numbers are sequential (e.g., `1.2.3-rancher.1`, `1.2.3-rancher.2`), PRs must merge in order. If multiple PRs are open for the same package, they need to coordinate merge order and rebase after earlier revisions merge.

For more on what details to provide QA for testing, see: [How to test charts straight from ob-team-charts](./docs/testing-from-ob-team-charts.md).

### PR Labels

The ORBS team uses these labels to track PR status:

- **`revision-hold`**: Another PR has a lower `-rancher.x` revision that must merge first. Once that PR merges, this label will be removed and the PR will need to be rebased.

- **`needs-rebase`**: The PR is behind main or has become stale. Contributor should rebase their PR to include recent changes.

- **`stale-revision-number`**: The revision number in this PR is already released or claimed by another PR further along in QA. Sync with the ORBS team to pick a new revision number.

## How does rebasing for Rancher Monitoring charts work with this repo?
Overall the process isn't too different, however how we manage a particular upstream version will be different.
In the new system, we will suffix each upstream version with a `-rancher.{num}` identifier.

Using that will give us a better identifier for our Rancher specific modifications that we use across Rancher minor versions.
Specifically some other ways this will benfit our team is:
- ORBS team maintains a single canonical version of upstream chart changes,
- `rancher-monitoring` and `rancher-project-monitoirng` rebase can be a single PR
  - Then followed up by PRs in `rancher/prometheus-federator` and all synced to `rancher/charts` in unison. 

Please review the [Monitoring Rebase doc](./docs/monitoring-rebase.md) for more details on the process this repo allows.

## Repo name ORBS vs O&B (ob)
The team has been renamed from O&B to ORBS. The repo name will remain the same.