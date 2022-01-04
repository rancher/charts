## Repository Validation / CI

In order to provide a way for CI to ensure that the current state of a repository is valid and all necessary commits that produce generated changes have been run by developers, `make validate` runs a series of checks on a clean Git repository.

Specifically, the workflow used by `make validate` does the following:
1. Ensure Git is clean; if not, fail.
2. Run `make charts`; if Git is no longer clean, fail and leave behind the assets.
3. **Only if `validate.url` and `validate.branch` are provided in the `configuration.yaml`**, pull in the specified Git repository, standardize the repository, and check each asset:
  - For any assets that exist in upstream, check if it is modified or does not exist in local. If so, copy it over, unzip it, and fail.
  - For any assets that exist in local but not in upstream, check if it corresponds to an entry in the `release.yaml`; if not, fail.
4. Run `make unzip`; if Git is no longer clean, fail.

### What is the release.yaml?

The `release.yaml` is only specified if `validate.url` and `validate.branch` are provided in the repository's `configuration.yaml`. It is created automatically if you run `make validate`, which will produce a list of assets that have been modified based on your upstream repository.

When a GitHub repository is provided for this repository to validate against, the scripts ensure that any changes introduced to the current repository make **no additions, modifications, or deletions** to the upstream repository's `charts/`, `assets/`, or `index.yaml`.

**However, if this were the case always, we would not be able add charts or make modifications to existing charts!** 

Therefore, to signal to the scripts that you are adding a new chart to upstream, making a modification to an existing chart, or removing a chart, you will need to specify the versions under `${CHART}`. 

For example:

```yaml
<chart>: 
- <version>
- <version>
- <version>
- ...
rancher-monitoring:
- 100.0.0+up16.6.0
rancher-monitoring-crd:
- 100.0.0+up16.6.0
fleet:
- 100.0.0+up0.3.6
fleet-agent:
- 100.0.0+up0.3.6
fleet-crd:
- 100.0.0+up0.3.6
longhorn:
- 100.0.0+up1.1.2
- 100.0.0+up1.2.0
longhorn-crd:
- 100.0.0+up1.1.2
- 100.0.0+up1.2.0
```
