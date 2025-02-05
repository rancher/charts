## Auto chart-bump

- Chart: ${{ env.CHART }}
- Version: ${{ env.new_version }}

---
## Review Checklist:
- [ ] CRDs
- [ ] templates folder if any
- [ ] Version
##### Checkpoints for Chart Bumps
`release.yaml`:
- [ ] Each chart version in release.yaml DOES NOT modify an already released chart. If so, stop and modify the versions so that it releases a net-new chart.
- [ ] Each chart version in release.yaml IS exactly 1 more patch or minor version than the last released chart version. If not, stop and modify the versions so that it releases a net-new chart.

`Chart.yaml and index.yaml`:
- [ ] The `index.yaml` file has an entry for your new chart version.
- [ ] The `index.yaml` entries for each chart matches the `Chart.yaml` for each chart.
- [ ] Each chart has ALL required annotations
- kube-version annotation
- rancher-version annotation
- permits-os annotation (indicates Windows and/or Linux)