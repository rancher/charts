## Staging Branch

This branch contains Packages and generated assets that have not been officially released yet.

See the README.md under `packages/`, `assets/`, and `charts/` for more information.

The following directory structure is expected:
```text
package/
  <package>/
  ...
assets/
  <package>/
    <chart>-<packageVersion>.tgz
  ...
charts/
  <package>
    <chart>
      <packageVersion>
        # Unarchived Helm chart
  ...
```

### Configuration

This repository branch contains a `configuration.yaml` file that is used to specify how it interacts with other repository branches.

#### Validate

This branch validates against the generated assets of the following branches to make sure it isn't overriding already released charts.
- release-v2.5 at https://github.com/rancher/charts.git

Before submitting any PRs, a Github Workflow will check to see if your package doesn't break any already released packages in these repository branches.

### Making Changes

As a developer making changes to a particular package, you will usually follow the following steps:

#### If this is the first time you are adding a package:

```shell
PACKAGE=<packageName>
mkdir -p packages/${PACKAGE}
touch packages/${PACKAGE}/package.yaml
```

See `packages/README.md` to configure the `packages/${PACKAGE}/package.yaml` file based on the Package that you are planning to add.

To make changes, see the steps listed below.

#### If the package already exists

If you are working with a single Package, set `export PACKAGE=<packageName>` to inform the scripts that you only want to make changes to a particular package.

This will prevent the scripts from running commands on every package in this repository.

You'll also want to update the `packageVersion` located in `packages/${PACKAGE}/package.yaml`.

See the section below for how to update this field.

Once you have made those changes, the Workflow will be:
```shell
make prepare # Instantiates the chart in the workingDir specified in the package.yaml
# Make your changes here to the workingDir directly here
make patch # Saves changes to generated-changes/
make clean # Cleans up your workingDir, leaving behind only the generated-changes/
```

Once your directory is clean, you are ready to submit a PR.

#### Versioning Packages

If this `major.minor.patch` (e.g. `0.0.1`) version of the Chart has never been released, reset the `packageVersion` to `01`.

If this `major.minor.patch` (e.g. `0.0.1`) version of the Chart has been released before, increment the `packageVersion`.

#### Separating multiple images within `charts/values.yaml`

After running `make prepare` if you see that the upstream version of the chart adds a new image in `packages/<package-name>/charts/values.yaml`, you have to separate those images. You can follow the below pattern:
```text
images:
  config_reloader:
    repository: rancher/mirrored-jimmidyson-configmap-reload
    tag: v0.4.0
  fluentbit:
    repository: rancher/mirrored-fluent-fluent-bit
    tag: 1.7.9
  fluentbit_debug:
    repository: rancher/mirrored-fluent-fluent-bit
    tag: 1.7.9-debug
  fluentd:
    repository: rancher/mirrored-banzaicloud-fluentd
    tag: v1.12.4-alpine-1
  nodeagent_fluentbit:
    os: "windows"
    repository: rancher/fluent-bit
    tag: 1.7.4
```

Every image repository has to be added against `repository` and it's tag should be added against `tag`. Rancher release script reads images and tags with these keys and populates `rancher-images.txt` file as one of its release assets.

### Porting over Charts / Assets from another Branch

In the Staging branch, porting over charts from another branch (e.g. `dev-v2.x+1`) requires you to copy the contents of that branch into your Staging branch, which can be done with the following simple Bash script. However, you will need to manually regenerate the Helm index since you only want the index.yaml on the Staging branch to be updated to include the new chart.

```bash
# Assuming that your upstream remote (e.g. https://github.com/rancher/charts.git) is named `upstream` 
# Replace the following environment variables
OTHER_BRANCH=dev-v2.x+1
STAGING_BRANCH=dev-v2.x
FORKED_BRANCH=dev-v2.x-with-port
NEW_CHART_DIR=charts/rancher-monitoring/rancher-monitoring/X.Y.Z
NEW_ASSET_TGZ=assets/rancher-monitoring/rancher-monitoring-X.Y.Z.tgz
git fetch upstream
git checkout upstream/${STAGING_BRANCH} -b ${FORKED_BRANCH}
git branch -u origin/${FORKED_BRANCH}
git checkout upstream/${OTHER_BRANCH} -- ${NEW_CHART_DIR} ${NEW_ASSET_TGZ}
helm repo index --merge ./index.yaml --url assets assets; # FYI: This will generate new 'created' timestamps across *all charts*.
mv assets/index.yaml index.yaml
git add ${NEW_CHART_DIR} ${NEW_ASSET_TGZ} index.yaml
git commit -m "Porting a chart from ${OTHER_BRANCH}"
git push --set-upstream origin ${FORKED_BRANCH}
# Create your pull request!
```

Once complete, you should see the following:
- The new chart should exist in `assets` and `charts`. Existing charts should not be modified.
- The `index.yaml`'s diff should show an additional entry for your new chart.
- The `index.yaml`'s diff should show modified `created` timestamps across all charts (due to the behavior of `helm repo index`).

No other changes are expected.

### Makefile

#### Basic Commands

`make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts.

`make prepare`: Pulls in your charts from upstream and creates a basic `generated-changes/` directory with your dependencies from upstream

`make patch`: Updates your `generated-changes/` to reflect the difference between upstream and the current working directory of your branch (note: this command should only be run after `make prepare`).

`make clean`: Cleans up all the working directories of charts to get your repository ready for a PR

`make charts`: Runs `make prepare` and then exports your charts to `assets/` and `charts/` and generates or updates your `index.yaml`.

#### Advanced Commands

`make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

`make template`: Updates the current directory by applying the configuration.yaml on [upstream Go templates](https://github.com/rancher/charts-build-scripts/tree/master/templates/template) to pull in the most up-to-date docs, scripts, etc. from [rancher/charts-build-scripts](https://github.com/rancher/charts-build-scripts)
