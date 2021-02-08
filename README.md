## Live Branch

This branch contains generated assets that have been officially released on charts.rancher.io.

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
```

### Configuration

This repository branch contains a `configuration.yaml` file that is used to specify how it interacts with other repository branches.

#### Sync

This branch syncs with the generated assets from the following branches:
- dev-v2.5-alt at https://github.com/rancher/charts.git (only latest assets)

To release a new version of a chart, please open the relevant PRs to one of these branches. 

Merging should trigger a sync workflow on pushing to these branches.

### Cutting a Release

In the Live branch, cutting a release requires you to run the `make sync` command.

This command will automatically get the latest charts / resources merged into the the branches you sync with (as indicated in this branch's `configuration.yaml`) and will fail if any of those branches try to modify already released assets.

If the `make sync` command fails, you might have to manually make changes to the contents of the Staging Branch to resolve any issues.

Once you successfully run the `make sync` command, the logs outputted will itemize the releaseCandidateVersions picked out from the Staging branch and make exactly two changes:

1. It will update the `Chart.yaml`'s version for each chart to drop the `-rcXX` from it

2. It will update the `Chart.yaml`'s annotations for each chart to drop the `-rcXX` from it only for some special annotations (note: currently, the only special annotation we track is `catalog.cattle.io/auto-install`).

Once you successfully run the `make release` command, ensure the following is true:
- The `assets/` and `charts/` directories each only have a single file contained within them: `README.md`
- The `released/assets/` directory has a .tgz file for each releaseCandidateVersion of a Chart that was created during this release.
- The `index.yaml` and `released/assets/index.yaml` both are identical and the `index.yaml`'s diff shows only two types of changes: a timestamp update or a modification of an existing URL from `assets/*` to `released/assets/*`.

No other changes are expected.

### Makefile

#### Basic Commands

`make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts.

`make sync`: Syncs the assets in your current repository with the merged contents of all of the repository branches indicated in your configuration.yaml

`make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

`make docs`: Pulls in the latest docs, scripts, etc. from the charts-build-scripts repository