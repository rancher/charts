## Charts Checklist (built for v0.8.x charts-build-scripts)

### Checkpoint 0: Validate `release.yaml`

Validation steps:
- [ ] Each chart version in `release.yaml` DOES NOT modify an already released chart. If so, stop and modify the versions so that it releases a net-new chart.
- [ ] Each chart version in `release.yaml` IS exactly 1 more patch version than the last released chart version. If not, stop and modify the versions so that it releases a net-new chart.

### Checkpoint 1: Compare contents of assets/ to charts/

Validation steps:
- [ ] Running `make unzip` to regenerate the `charts/` from scratch, then `git diff` to check differences between `assets/` and `charts/` yields NO differences or innocuous differences.

IMPORTANT: Do not undo these changes for future steps since we want to keep the charts/ that match the current contents of assets!

### Checkpoint 2: Compare assets against index.yaml

Validation steps:
- [ ] The `index.yaml` file has an entry for each chart version.
- [ ] The `index.yaml` entries for each chart matches the `Chart.yaml` for each chart.
- [ ] Each chart has ALL required annotations
  - kube-version annotation
  - rancher-version annotation
  - permits-os annotation (indicates Windows and/or Linux)