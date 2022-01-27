## Developer Workflow

### Introducing a new package

Introducing a new package usually requires two things: creating a directory under `packages` and filling in a `package.yaml`.

The following utility script can be used to create the necessary `package.yaml` file in the right location:

```shell
PACKAGE=<packageName> # can be nested, e.g. rancher-monitoring/rancher-windows-exporter is acceptable
mkdir -p packages/${PACKAGE}
touch packages/${PACKAGE}/package.yaml
```

Once the `packages/${PACKAGE}/package.yaml` file has been created, you will need to fill it in. A full explanation of the expected fields in the `package.yaml` can be found under [docs/packages.md](./packages.md); however, here are some simple common configurations you can use:

#### Local Chart

```yaml
url: local
# Depending on your organization, one of the following two fields might also need to be provided
# version: x.y.z
# packageVersion: 1
```

*Note: For local charts, you will also need to commit the Helm chart itself under `packages/${PACKAGE}/charts`.*

#### Upstream Chart From a Git Repository

```yaml
url: https://github.com/ORG/REPO.git
commit: xXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX
subdirectory: charts/mychart # optional
# Depending on your organization, one of the following two fields might also need to be provided
# version: x.y.z
# packageVersion: 1
```

#### Upstream Chart From a Chart Archive

```yaml
url: https://github.com/ORG/REPO/releases/download/VERSION/CHART.tgz
subdirectory: charts/mychart # optional
# Depending on your organization, one of the following two fields might also need to be provided
# version: x.y.z
# packageVersion: 1
```

### Making Changes To Packages

As a developer making changes to a particular package, you will usually follow the following steps:
0. If you are working with a single `Package`, set `export PACKAGE=<packageName>`
  - Note: This inform the scripts that you only want to make changes to a particular package. This will prevent the scripts from running commands on every package in this repository.
  - Note: Starting v0.3.0 of the scripts, `PACKAGE` can refer to a nested structure, e.g. you can place packages under `packages/my-stuff/package-1` and `packages/my-stuff/package-2`. If you want to target all packages in this nested structure, set `PACKAGE=my-stuff`. If you want to target a specific package in this nested structure, set `PACKAGE=my-stuff/package-1`. It should be noted, however, that `make patch` will **only** work if you point to a specific package, so setting `PACKAGE=my-stuff` would cause it to fail.
1. If necessary, update the `version` or `packageVersion` field in the `package.yaml`. Then run `make charts` and commit the changes. 
  - Note: It is recommended that your commit message says something along the lines of `Bump ${PACKAGE} version to ${NEW_VERSION}`.
2. Run `make prepare`. This will produce a chart under `packages/${PACKAGE}/charts` that will serve as your working copy of the chart.
3. Make modifications **directly** to the working copy of the chart in `packages/${PACKAGE}/charts`. 
  - Note: **Do not modify `charts/${PACKAGE}/${CHART}/${VERSION}/` directly** since it will be overridden by changes to `packages/${PACKAGE}/charts`.
4. When you are happy with your changes, run `make patch`. This will automatically construct a `packages/${PACKAGE}/generated-changes` directory after assessing your current working directory in `packages/${PACKAGE}/charts`.
  - Note: **You should never directly modify `packages/${PACKAGE}/generated-changes`** unless you are trying to change `packages/${PACKAGE}/generated-changes/dependencies` to update your chart dependencies. This directory is automatically constructed / destroyed by `make patch` to save the least amount of information necessary to reconstruct your working directory on a `make prepare`.
5. Run `make clean` to clean up your working directory. Then, commit your changes to Git with a commit message that indicates what you have changed.
  - Note: **To avoid losing unsaved changes, do not run `make clean` unless you have already ran `make patch`.** `make clean` will delete the `packages/${PACKAGE}/charts` directory, so any modifications you made to the working copy of the chart will be lost.
6. To test your changes, run `make charts`. This will automatically create an `assets/${PACKAGE}/${CHART}-${VERSION}.tgz`, the `charts/${PACKAGE}/${CHART}/${VERSION}/` directory, and create or modify an existing `index.yaml`. Commit these changes to Git, usually with a commit titled `make charts`.
  - Note: If you push the `make charts` commit to a repository, that repository would be a valid Helm repository to serve your chart.

If you need to make additional changes after testing, repeat steps 2-6. 

If your repository is configured to use upstream validation (e.g. check if `validation.url` and `validation.branch` is specified in the root `configuration.yaml`), you will also need to add this new chart's name and version to the `release.yaml` or else you will fail CI. If you run `make validate` locally, it will automatically generate this file for you.

For more information on how to do this or why this is required, please see [`docs/validation.md`](docs/validation.md).

Otherwise, you are ready to make a PR!

### Rebasing An Existing Package

For forked charts only (e.g. any chart where the `package.yaml` does not have `url: local`), currently the scripts do not have good support for rebasing charts to a new upstream. 

The reason why this is the case is that the patch files defined under `packages/${PACKAGE}/generated-changes/patch/*` are based on the old upstream, so when you change the URL it is unable to reconcile how to apply the patch.

Therefore, the best way to currently rebase is to follow the following workflow:

0. Set `PACKAGE=<packageName>` pointing to the specific package you want to work with.
1. If the chart has not been released yet, delete your existing charts, assets, and `index.yaml` entries corresponding to the chart you are rebasing by running `CHART=<chart> VERSION=<version> make remove` for each chart (e.g. if you have a chart that also packages a CRD chart, you will need to run `make remove` twice for the main chart and the CRD chart). Then, commit your changes to Git with a commit message that says "Remove charts/assets for ${CHART} ${VERSION}"
2. Without making any other changes, run `make prepare`. This will apply your existing patches on your existing upstream to produce `packages/${PACKAGE}/${workingDir}` (usually `packages/${PACKAGE}/charts`).
3. Modify the `package.yaml` to point to your new upstream.
4. Run `make patch`. This will destroy the current contents of `packages/${PACKAGE}/generated-changes` and reconstruct everything as if you were patching the new upstream with your **existing** chart. 
5. Run `make clean`. Then, commit your changes to Git with a commit message that says "Rebase ${PACKAGE} from ${OLD_REF} to ${NEW_REF}"; this will make it easier for reviewers to see what you actually introduced in the next commit.
6. Follow the same developer workflow as defined under `Making Changes to Packages` to change the version, add back in changes introduced by upstream, and generate charts / assets.

Once these steps are compplete, you should have something similar to the following four commits:
1. "Remove charts/assets for ${CHART} ${VERSION}"
2. "Rebase ${PACKAGE} from ${OLD_REF} to ${NEW_REF}"
3. "Add changes from rebasing ${CHART} to ${NEW_VERSION}"
4. "make charts"

As a result, developers reviewing your chart can see changes made to `packages/` by reviewing changes between commit 2 and commit 3; they can also inspect changes introduced to `charts/` by viewing the overall diff on the PR, since the old assets will show as renamed / modified.

You are ready to make a PR!

### Known Issue: Making Changes to the Version of an Existing Package

If you are working with a repository using `charts-build-scripts` that uses remote validation (e.g. `validate.url` and `validate.branch` are provided in the `configuration.yaml`) and you are making a change that would modify the version of an existing package (e.g. replacing a version like `0.1.2-rc3` with `0.1.2-rc4`), please see the section `Modifying Chart Versions That Exist In Upstream` within [`docs/validation.md`](docs/validation.md) for how to ensure CI still passes after making your change.

### Versioning Packages

Generally, repositories that are using `charts-build-scripts` use one of the following two types of built-in versioning schemes for packages:

#### Version

This versioning scheme is used if `version` is specified in the `package.yaml`. 

If a valid semver for `version` is provided, the final version of the chart will be the same as the `version` provided. 

The only caveat is that **if** the main chart corresponds to some upstream chart whose chart version is not the same as the `version` provided, then the upstream version will be appended as a build annotation following the pattern `<version>+up<upstreamVersion>`. 

*e.g. If `version` is 100.0.0 and the upstream chart's version is `1.2.3`, the final version will be `100.0.0+up1.2.3`.*

#### PackageVersion

This versioning scheme is used if `packageVersion` is specified in the `package.yaml`. 

If a two-digit `packageVersion` is provided, the final version of the chart that is produced under the generated assets will be the same as the version specified by the main chart in the package, except the patch version of will be `int(originalPatchVersion * 100 + packageVersion)`.

Examples:
- If the main chart version is `1.2.3` and the packageVersion is `1`, the final chart version will be `1.2.301`.
- If the main chart version is `1.2.3` and the packageVersion is `56`, the final chart version will be `1.2.356`.
- If the main chart version is `2.1.0` and the packageVersion is `12`, the final chart version will be `2.1.12`.
  - *Note: It is not `2.1.012` since a leading zero in the patch version is invalid semver.*

##### When should I update the packageVersion?

You should generally update the `packageVersion` **once per release**.

If the chart version you are currently modifying has already been released before, you should **bump the `packageVersion` by 1** to ensure you aren't modifying an already released chart. 

*e.g. if chart version `1.2.301` is released, bumping the `packageVersion` to `2` will result in `1.2.302` being released next.*

If the chart version you are currently modifying has never been released before, you should **reset the `packageVersion` to 1**.  

*e.g. if chart version `1.2.301` is released but you are currently working on releasing a package based on `1.3.0`, you should reset the `packageVersion` to `1` to release `1.3.1`.*

*Note: You should reset the packageVersion to 1 instead of 0 since the scripts will always introduce at least one change to the chart.*

### Updating Dependencies / Subcharts

The scripts used to maintain this repository natively supports managing dependencies / subcharts for Helm charts. 

Subcharts can be added by creating a file under `packages/${PACKAGE}/generated-changes/dependencies/${SUBCHART}/dependency.yaml`. 

The following utility script can be used to create the necessary `dependency.yaml` file in the right location:

```shell
PACKAGE=<packageName>
SUBCHART=<subchartName>
mkdir -p packages/${PACKAGE}/generated-changes/dependencies/${SUBCHART}
touch packages/${PACKAGE}/generated-changes/dependencies/${SUBCHART}/dependency.yaml
```

Once the `dependency.yaml` file has been created, you will need to fill it in. The `dependency.yaml` supports a **subset** of `package.yaml` fields (namely, those associated with `UpstreamOptions`; i.e. you can specify local charts, GitHub Repositories, or Chart Archives). More information on UpstreamOptions can be found in [docs/packages.md](./packages.md).

Once declared, `make prepare` will automatically pull in your dependency under `packages/${PACKAGE}/charts/charts` and add a corresponding entry to the `packages/${PACKAGE}/charts/Chart.yaml` (or `requirement.yaml`, for Helm charts using the older `apiVersion: v1`). You will also be able to patch your dependency from there as if it was part of the original main chart.

*Note: The name of your subchart, and the alias you can use to override settings of your subchart from the main chart, will be dependent on the name of the directory you place the `dependency.yaml` in. For example, if you created your `dependency.yaml` under `packages/mypackage/generated-changes/dependencies/mydep/dependency.yaml` and ran `PACKAGE=mypackage make prepare`, all subchart settings will be located under the main chart's `values.yaml` under `mydep.*` (e.g. `mydep.enabled`), even if the chart `mydep` points to is named something else.*

*Note: A common practice for managing dependencies via these scripts is to keep the actual patches on the dependency in a separate package and refer to it in your main chart. To take this approach, declare your dependency as a separate packages under `packages/${DEPENDENCY}` and simply specify `url: packages/${DEPENDENCY}` in the `dependency.yaml` of your main chart. Then, on a `make prepare`, it will prepare the dependency's package first and pull it in on trying to prepare the main chart. It should also be noted that it is the developer's responsibility to ensure that no cyclical dependencies are introduced in this fashion.*

*Note: if you manage a dependency as a separate package, it's often a good idea to set `doNotRelease: true` on that dependency package's `package.yaml` to indicate that the dependency should not be independently released. This prevents `make charts` from generating assets for the dependency, since it will already be packaged directly into your main chart.*

#### Known Issue: Managed Files

In any Helm chart managed by these scripts, we consider the `Chart.yaml` / `requirements.yaml` to be `Managed Files` since they are the only files that end up going through a three-way merge. 

Specifically, the three-way merge occurs because there are three parties involved in applying changes on a `make prepare`:
1. The upstream chart source, which provides the base `Chart.yaml` / `requirements.yaml`
2. The scripts themselves, which make changes to support adding in dependencies based on those specified under `generated-changes/dependencies`.
3. The user, who commits patches to those files after running `make patch`

As a result, on updating dependencies for charts, these files are prone to having conflicts. 

The only workaround for this issue is to delete the patch files manually (e.g. `rm packages/${PACKAGE}/generated-changes/patch/Chart.yaml.patch` and/or `rm packages/${PACKAGE}/generated-changes/patch/requirements.yaml.patch`), run `make prepare`, and redo the patches you added to these files manually.

### Making Changes to Released Charts

If a chart version that you want to make changes to has already been released (i.e. the chart already exists in `charts/`, `assets/` and `index.yaml` and the `Package` that was tracking that chart version has moved on to a future version), you will usually follow the following steps:

1. Make the change directly to the `charts/{chart}/{version}` files
2. Run `make zip` to automatically zip up `charts/{chart}/{version}` -> `assets/{chart}-{version}.tgz` and update the `index.yaml`. This might also introduce some changes to `charts/{chart}/{version}`, such as when you add an annotation to `charts/{chart}/{version}/Chart.yaml` that needs to be re-ordered alphabetically.

In addition, if your repository is configured to use upstream validation (e.g. check if `validation.url` and `validation.branch` is specified in the root `configuration.yaml`), you will also need to add this modified chart's name and version to the `release.yaml` or else you will fail CI. If you run `make validate` locally, it will automatically generate this file for you.

For more information on how to do this or why this is required, please see [`docs/validation.md`](docs/validation.md).

Otherwise, you are ready to make a PR!

### Troubleshooting

Open up an issue on [https://github.com/rancher/charts-build-scripts](https://github.com/rancher/charts-build-scripts).

#### Maintainers
- aiyengar2 (arvind.iyengar@suse.com)
- jiaqiluo (jiaqi.luo@suse.com)