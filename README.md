## charts

This is charts repo to automate system charts and adding overlays files on top of it.

Charts will have two categories: 

1. Charts that Rancher created and maintained (**Rancher original**).

2. Charts that Rancher modified from upstream (**Rancher modified**). 

**Rancher original** chart is created and maintained by Rancher Team, such as rancher-cis-benchmark, rancher-k3s-upgrader. 

**Rancher modified** chart is modified from upstream chart, while there are customizations added into the upstream chart from rancher side.

For **Rancher original** charts, it should have the following tree structure

```text
packages/${CHART_NAME}/
  charts/                   # regular helm chart directory
    templates/
    Chart.yaml
    values.yaml
```

For **Rancher original** charts with a crds directory, it should have the following tree structure

```text
packages/${CHART_NAME}/
  package.yaml              # metadata manifest to enable or disable crds generation
  charts/                   # regular helm chart directory
    templates/
    crds/
    Chart.yaml
    values.yaml
```

For **Rancher modified** charts, it should have the following tree structure

```text
packages/${CHART_NAME}/
  package.yaml              # metadata manifest containing upstream chart location, package version
  ${CHART_NAME}.patch       # patch file containing the diff between modified chart and upstream
  overlay/*                 # overlay files that needs to added on top of upstream, for example, questions.yaml
```

A regular `package.yaml` will have the following content:

```yaml
url: https://charts.bitnami.com/bitnami/external-dns-2.20.10.tgz # url to fetch upstream chart, omit this field for a rancher original chart
packageVersion: 00 # packageVersion of modified charts, producing a $version-$packageVersion chart. For example, if istio 1.4.7 is modified with changes, rancher produces a 1.4.700 chart version that includes the modification rancher made on top of upstream charts.
generateCRDChart:
  enabled: true
```

Here is an **example** of upstream chart based on git repository

```yaml
url: https://github.com/open-policy-agent/gatekeeper.git  # Url to fetch upstream chart from git
subdirectory: chart/gatekeeper-operator # Sub directory for helm charts in git repo
type: git # optinal, indicate that upstream chart is from git
commit: v3.1.0-beta.8 # the revision of git repo
packageVersion: 00 # package version
generateCRDChart:
  enabled: true
```

Here is an **example** of local chart with a crds directory

```yaml
generateCRDChart:
  enabled: true
```

### Workflow

Modifying **Rancher original** charts is the same workflow as modifying helm charts. First make changes into `charts/` and commit changes. CI will automatically upload artifacts if file contents have been changed.

Modifying **Rancher modified** takes extra steps, as it requires modifications to be saved into patch files so that later it can retrieve the chart based on upstream chart and patch files.

The step includes:

1. Run `make CHART={CHART_NAME} prepare`
   
   This prepares `charts` with the current upstream chart and current patch. 
   
2. Change the version in `package.yaml`. If upstream chart needs to be updated, update url to point the latest chart. `packageVersion` also needs to updated.

3. Make modification to your charts. 

4. Run `make CHART={CHART_NAME} patch`
 
   This will compare your current chart with upstream chart and generate the correct patch. 
   
5. Run `make CHART={CHART_NAME} clean`
   
   This will clean up the `charts` directory so that it won't be committed.

This repo provides a [workflow](./.github/workflows) that automatically uploads patch files and tarball of charts. Commit will only need to update `package/${chart-name}/charts` and make sure patches are 
up-to-date with the latest chart. It also automatically build github pages to serve `index.yaml` and artifacts of charts.

### Experimental: Splitting CRDs from an upstream package into a separate package

**Note to Contributers:** This flag can only be used to create separate CRD charts if your chart meets the following three requirements:
- The chart defines one or more CRDs
- The chart is based on an upstream chart and includes a `package.yaml` (if this is not the case, you will need to manually create a separate CRD chart)
- The chart tries to install some default CRs based on the CRDs that it defines (if this is not the case, you should place the CRDs directly within the `templates/` directory of the chart; using a CRD chart is only necessary since rendering the chart will fail since the `kind` of the default CRs cannot be found in the cluster as the CRD is not installed yet).

There are cases in which upstream charts import CRDs into a cluster using the Helm 3 `crd/` directory, which allows a user to first install the CRDs before rendering the templates created by the chart. However, using this approach has certain caveats [as documented by Helm](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/), such as an inability to upgrade / delete those CRDs and or use the `--dry-run` flag on the package before installing the CRDs. As a result, it may be advised to move those CRDs into a separate chart under the `templates/` directory so that the lifecycle of those CRDs can continue to be managed by Helm.

However, in the current `rancher/charts` model, this would require deleting the CRDs from the upstream chart (which introduces significant changes to the package's patch) and maintaining a separate CRD chart that also needs to be kept up to date with the upstream chart. This poses several challenges, including but not limited to:
- Keeping the version of the Rancher chart and the CRD chart consistent
- Keeping the annotations added to the CRD chart in line with those added to the Rancher chart
- Adding a validation YAML to the Rancher chart to direct the user to install the CRD chart before installing the Rancher chart if CRDs do not currently exist on the server
- Viewing the patch between the CRDs introduced by the upstream chart and the CRDs within the CRD chart

To resolve this, `rancher/charts` has a flag that can be added to the `package.yaml` of any Rancher chart that allows you to specify `generateCRDChart.enabled=true`. When this mode is enabled, the following changes are applied during each step of the `rancher/charts` developer workflow:

1. On running `make CHART={CHART_NAME} prepare:

   After running the default prepare script to pull the chart from upstream and apply the patch, a new directory called `charts-crd` is also created alongside `charts`. This will represent your new CRD chart. Any CRDs located within the Rancher chart in `charts/crd/` will be relocated to `charts-crd/templates/` and a new `charts-crd/Chart.yaml` (with chart names `{CHART_NAME}-crd`) and `charts-crd/README.md` will be generated. The `charts-crd/Chart.yaml` and `charts/Chart.yaml` will also be updated with the relevant annotations used by Rancher to auto-install the CRD chart from Dashboard.

   If you are using the `generateCRDChart.assumeOwnershipOfCRDs` flag, the CRDs will instead be located in `charts-crd/crd-manifest/*` and some additional resources (ConfigMap, Jobs, and RBAC resources) will be created in the `charts-crd/templates` directory instead. This option should only be enabled if the chart is expected to be deployed in a setting where all or a subset of your CRDs may or may not already exist, in which case your CRD chart may want to assume ownership of the CRDs to prevent a failure on deploy.

   In addition, a new file `charts/templates/validate-install-${CHART_NAME}-crd.yaml` will be added to your Rancher chart that is automatically configured to validate whether the CRDs that have been moved to the CRD chart are installed onto your cluster before trying to render the Rancher chart. For example, here is an error you might encounter if you try to install the Rancher chart first:

   ```
   Error: execution error at ({CHART_NAME}/templates/validate-install-{CHART_NAME}-crd.yaml:15:5): Required CRDs are missing. Please install the {CHART_NAME}-crd chart before installing this chart.
   ```

   See `scripts/prepare-crds` for more information on the default templates used for generating these files.

2. On making modification to either chart or running `make CHART={CHART_NAME} patch`
 
   The experience of modifying values within the `charts` directory and making a new patch is unchanged. The same workflow also applies to the `charts-crd` directory with two caveats:
   - Changes to `charts/templates/validate-install-${CHART_NAME}-crd.yaml`, `charts-crd/Chart.yaml`, and `charts-crd/README.md` will be ignored / not be shown in the patch as they are not expected to be updated
   - Any changes to `charts-crd/templates/*` (`charts-crd/crd-manifest/*` if you are using the `generateCRDChart.assumeOwnershipOfCRDs` flag) will show up in the patch as if you had changed the relevant file within `charts/crd/*`.

   Files added to the `overlay` directory will only overlay onto the Rancher chart, not the CRD chart.
   
3. On running `make CHART={CHART_NAME} clean`
   
   This will clean up both the `charts` directory and the `charts-crd` directory so that either directory won't be committed.

4. On running `make CHART={CHART_NAME} charts`

   A tarball for both the original chart and the CRD chart will be generated.

Some more considerations when migrating to using this flag:
- After adding this flag to a chart, you will have to look through the upstream chart and manually remove any CRD build specific code from the upstream chart (i.e. removing `helm.sh/hook: crd-install` from the CRD files, removing any cleanup Jobs introduced by the upstream chart to automatically delete CRDs on uninstall, etc.)
- The CRDs moved to their own chart must not contain any code that was pulled from helper templates located within the main chart. If it is found that this is necessary for any chart, please submit a feature request.

See `packages/rancher-monitoring` for an example of a chart that currently uses this flag.


### Override existing Chart

By default CI script doesn't allow changes to be made against existing chart. In order to make changes you have to bump chart version. There is a backdoor method to make changes to your existing chart without having to bump version. You can delete the tar.gz file you want to override and commit the change. Here is an example of [commit](https://github.com/rancher/charts/commit/3ec3d344c7e20eda6d2c6e0e9d33a4e00a33edfc#diff-db2aa3c5b9630208bd8568672c84f408).

### Helm repo index

To add this repo as a helm repo, run

```text
helm repo add ${repo_name} https://charts.rancher.io
```

To use a forked version of this chart repo, you can try either of these:

1. If you just need to test chart tar.gz file, you can run `make CHART=${name} charts` to generate tar.gz files. It will be generated under `docs/${chart_name}`.

2. You can also setup github page to serve your tar.gz files on your forked repo. Github pages usually requires you to have this set up on [specific branches](https://help.github.com/en/github/working-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#choosing-a-publishing-source). 

3. You can directly add `https://github.com/rancher/charts` into rancher catalog. In order to show all the charts you have to run `make CHART=${chart_name} prepare` and make sure there is `chart-original` folder on each chart folder if your chart relies on a upstream chart.

### Makefile

`make bootstrap`: 

Download binaries that are needed for ci scripts.

`make prepare`: 

Prepare the chart for modification. This will apply the upstream chart with the current patch. Use `CHART=${NAME}` for specific chart.

`make charts`: 

Generate tarball for each charts. Use `CHART=${NAME}` for specific chart.

`make patch`: 

Compare the current chart with upstream and generate patch file. Use `CHART=${NAME}` for specific chart. 

`make validate`:

Validate if patch file can be applied.

`make mirror`: 

Run image mirroring scripts.(Experimental)

