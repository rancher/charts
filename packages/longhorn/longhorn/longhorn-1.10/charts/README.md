# Longhorn Charts
![Release Charts](https://github.com/longhorn/charts/workflows/Release%20Charts/badge.svg)

This repository contains the charts used for installing Longhorn using Helm. Currently, this chart only contains the following chart:
- `longhorn` - The chart for Longhorn. For the actual Longhorn repository, go [here](https://github.com/longhorn/longhorn).

## Adding the Chart
```
$ helm repo add longhorn https://charts.longhorn.io
$ helm repo update
```

## Releasing New Charts
When ready to release a new chart version or add a new chart, copy the chart directory from the source repository into the `charts/` directory. Make sure the chart directory is named after the actual chart (for example: `longhorn/`).

Once pushed, GitHub Actions will look for any changes to charts in the `charts/` directory since the last tagged release in the repository, package any changed charts, and then release them on `GitHub Pages`.

Note that changes should only be synced to this repository when ready for a new release. GitHub Actions will fail if making changes to the charts in this repository directly, as Chart Releaser will not attempt to override old chart releases.
