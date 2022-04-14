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

### Cutting a Release

In the Live branch, cutting a release requires you to copy the contents of the Staging branch into your Live Branch, which can be done with the following simple Bash script.

```bash
# Assuming that your upstream remote (e.g. https://github.com/rancher/charts.git) is named `upstream` 
# Replace the following environment variables
STAGING_BRANCH=dev-v2.x
LIVE_BRANCH=release-v2.x
FORKED_BRANCH=release-v2.x.y
git fetch upstream
git checkout upstream/${LIVE_BRANCH} -b ${FORKED_BRANCH}
git branch -u origin/${FORKED_BRANCH}
git checkout upstream/${STAGING_BRANCH} -- charts assets index.yaml
git add charts assets index.yaml
git commit -m "Releasing chart"
git push --set-upstream origin ${FORKED_BRANCH}
# Create your pull request!
```

If you run into mass mode changes after checking out try the following:
```bash
git reset
git diff -p --diff-filter=ACM | grep -E  '^(diff|old mode|new mode)' | sed -e 's/^old/NEW/;s/^new/old/;s/^NEW/new/' | git apply
```

Once complete, you should see the following:
- The `assets/` and `charts/` directories have been updated to match the Staging branch. All entires should be additions, not modifications.
- The `index.yaml`'s diff shows only adds additional entries and does not modify or remove existing ones.

No other changes are expected.

### Cutting an Out-Of-Band Chart Release

Similar to the above steps, cutting an out-of-band chart release will involve porting over the new chart from the Staging branch via `git checkout`. However, you will need to manually regenerate the Helm index since you only want the index.yaml on the Live branch to be updated to include the single new chart.

Use the following example Bash script to execute this change:

```bash
# Assuming that your upstream remote (e.g. https://github.com/rancher/charts.git) is named `upstream` 
# Replace the following environment variables
STAGING_BRANCH=dev-v2.x
LIVE_BRANCH=release-v2.x
FORKED_BRANCH=release-v2.x.y
NEW_CHART_DIR=charts/rancher-monitoring/rancher-monitoring/X.Y.Z
NEW_ASSET_TGZ=assets/rancher-monitoring/rancher-monitoring-X.Y.Z.tgz
git fetch upstream
git checkout upstream/${LIVE_BRANCH} -b ${FORKED_BRANCH}
git branch -u origin/${FORKED_BRANCH}
git checkout upstream/${STAGING_BRANCH} -- ${NEW_CHART_DIR} ${NEW_ASSET_TGZ}
helm repo index --merge ./index.yaml --url assets assets; # FYI: This will generate new 'created' timestamps across *all charts*.
mv assets/index.yaml index.yaml
git add ${NEW_CHART_DIR} ${NEW_ASSET_TGZ} index.yaml
git commit -m "Releasing out-of-band chart"
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

`make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

`make template`: Updates the current directory by applying the configuration.yaml on [upstream Go templates](https://github.com/rancher/charts-build-scripts/tree/master/templates/template) to pull in the most up-to-date docs, scripts, etc. from [rancher/charts-build-scripts](https://github.com/rancher/charts-build-scripts)
