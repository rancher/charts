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

For **Rancher modified** charts, it should have the following tree structure

```text
packages/${CHART_NAME}/
  package.yaml              # metadata manifest containing upstream chart location, package version
  ${CHART_NAME}.patch       # patch file containing the diff between modified chart and upstream
  overlay/*                 # overlay files that needs to added on top of upstream, for example, questions.yaml
```

A regular `package.yaml` will have the following content:

```yaml
url: https://charts.bitnami.com/bitnami/external-dns-2.20.10.tgz # url to fetch upstream chart
packageVersion: 00 # packageVersion of modified charts, producing a $version-$packageVersion chart. For example, if istio 1.4.7 is modified with changes, rancher produces a 1.4.700 chart version that includes the modification rancher made on top of upstream charts.
```

Here is an example of upstream chart based on git repository

```yaml
url: https://github.com/open-policy-agent/gatekeeper.git  # Url to fetch upstream chart from git
subdirectory: chart/gatekeeper-operator # Sub directory for helm charts in git repo
type: git # optinal, indicate that upstream chart is from git
commit: v3.1.0-beta.8 # the revision of git repo
packageVersion: 00 # package version
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
   
   This will clean up the `charts` directory so that it won't committed.

This repo provides a [workflow](./.github/workflows) that automatically uploads patch files and tarball of charts. Commit will only need to update `package/${chart-name}/charts` and make sure patches are 
up-to-date with the latest chart. It also automatically build github pages to serve `index.yaml` and artifacts of charts.

### Override existing Chart

By defauly CI script doesn't allow changes to be made against existing chart. In order to make changes you have to bump chart version. There is a backdoor method to make changes to your existing chart without having to bump version. You can delete the tar.gz file you want to override and commit the change. Here is an example of [commit](https://github.com/rancher/charts/commit/8be888076487e23a24121a532d25b9bf9ea936f3).

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
