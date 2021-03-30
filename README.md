## Staging Branch

This branch contains generated assets that have not been officially released yet.

The following directory structure is expected:
```text
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

#### Sync

This branch syncs with the generated assets from the following branches:
- dev-v2.6-source at https://github.com/rancher/charts.git

To release a new version of a chart, please open the relevant PRs to one of these branches. 

Merging should trigger a sync workflow on pushing to these branches.

#### Validate

This branch validates against the generated assets of the following branches to make sure it isn't overriding already released charts.
- release-v2.6 at https://github.com/rancher/charts.git (only latest assets)

Before submitting any PRs, a Github Workflow will check to see if your package doesn't break any already released packages in these repository branches.

### Cutting a Release

In the Staging branch, cutting a release involves moving the contents of the `assets/` directory into `released/assets/`, deleting the contents of the `charts/` directory, and updating the `index.yaml` to point to the new location for those assets.

This process is entirely automated via the `make release` command.

Once you successfully run the `make release` command, ensure the following is true:
- The `assets/` and `charts/` directories each only have a single file contained within them: `README.md`
- The `released/assets/` directory has a .tgz file for each releaseCandidateVersion of a Chart that was created during this release.
- The `index.yaml` and `released/assets/index.yaml` both are identical and the `index.yaml`'s diff shows only two types of changes: a timestamp update or a modification of an existing URL from `assets/*` to `released/assets/*`.

No other changes are expected.

Note: these steps should be taken only after following the steps to cut a release to your Live Branch.

### Makefile

#### Basic Commands

`make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts.

`make sync`: Syncs the assets in your current repository with the merged contents of all of the repository branches indicated in your configuration.yaml

`make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

`make docs`: Pulls in the latest docs, scripts, etc. from the charts-build-scripts repository

`make release`: moves the contents of the `assets/` directory into `released/assets/`, deletes the contents of the `charts/` directory, and updates the `index.yaml` to point to the new location for those assets.
