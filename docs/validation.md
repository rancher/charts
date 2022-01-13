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

### Modifying Chart Versions That Exist In Upstream

One of the caveats with using the `release.yaml` is that **renames are not supported** (e.g. you cannot remove and replace a chart in a single step). 

As a result, if you attempt to modify a version of a chart that already exists in upstream, **both the old version and the new version must exist in the release.yaml for CI to pass**. Once the changes have been merged, you can later remove the old version from the release.yaml (usually as part of a release process).

To give a concrete example of such a scenario, let's say that you have currently committed `my-chart` version `0.1.2-rc3`. You then take the following steps:
1. You modify the `package.yaml` to point at a new upstream URL that points to `0.1.2-rc4` and resolve any conflicts with the patch files under `packages/my-chart-package/generated-changes`
2. You run `CHART=my-chart VERSION=0.1.2-rc3 make remove` to delete the older version of the chart
3. You run `make charts` to produce the new assets and charts for `my-chart` version `0.1.2-rc4`.
4. You modify the release.yaml to **replace** `my-chart[0] = 0.1.2-rc3` with `my-chart[0] = 0.1.2-rc4`.
4. You make a PR to your repository.

In this case, CI will fail since you are attempting to remove `0.1.2-rc3` but it is not tracked in the `release.yaml`.

Therefore, the correct resolution would be to leave your `release.yaml` as:

```yaml
...
my-chart:
- 0.1.2-rc3
- 0.1.2-rc4
...
```

That way, both the removal of `0.1.2-rc3` and the addition of `0.1.2-rc4` are accepted. Later, you can remove `0.1.2-rc3` once the PR has been committed.
