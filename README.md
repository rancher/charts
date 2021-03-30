## Source Branch

This branch contains packages that contain Packages that will be synced to another branch.

See the README.md under `packages/` for more information.

The following directory structure is expected:
```text
package/
  <package>/
```

### Configuration

This repository branch contains a `configuration.yaml` file that is used to specify how it interacts with other repository branches.

#### Validate

This branch validates against the generated assets of the following branches to make sure it isn't overriding already released charts.
- dev-v2.6 at https://github.com/rancher/charts.git
- release-v2.6 at https://github.com/rancher/charts.git (only latest assets)

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

You'll also want to update the `packageVersion` and `releaseCandidateVersion` located in `packages/${PACKAGE}/package.yaml`.

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

If this `major.minor.patch` (e.g. `0.0.1`) version of the Chart has never been released, reset the `packageVersion` to `01` and the `releaseCandidateVersion` to `00`.

If this `major.minor.patch` (e.g. `0.0.1`) version of the Chart has been released before:
- If this is the first time you are making a change to this chart for a specific Rancher release (i.e. the current `packageVersion` has already been released in the Live Branch), increment the `packageVersion` by 1 and reset the `releaseCandidateVersion` to `00`.
- Otherwise, only increment the `releaseCandidateVersion` by 1.

### Makefile

#### Basic Commands

`make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts.

`make prepare`: Pulls in your charts from upstream and creates a basic `generated-changes/` directory with your dependencies from upstream

`make patch`: Updates your `generated-changes/` to reflect the difference between upstream and the current working directory of your branch (note: this command should only be run after `make prepare`).

`make clean`: Cleans up all the working directories of charts to get your repository ready for a PR

#### Advanced Commands

`make charts`: Runs `make prepare` and then exports your charts to `assets/` and `charts/` and generates or updates your `index.yaml`.

`make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

`make docs`: Pulls in the latest docs, scripts, etc. from the charts-build-scripts repository