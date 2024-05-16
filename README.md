## Rancher Charts

This repository contains Helm charts served by Rancher Apps & Marketplace.

- More information on `how to make changes` to this repository: [`docs/developing.md`](docs/developing.md).
- More information on `experimental features`: [`docs/experimental.md`](docs/experimental.md).
- More information on `commands` that can be run in this repository: [`docs/makefile.md`](docs/makefile.md).
- More information on `Packages`: [`docs/packages.md`](docs/packages.md).
- More information on `CI validation`: [`docs/validation.md`](docs/validation.md).
- [Issues](#issues)
- [Branches](#branches)
- [Making Changes](#making-changes)
- [Adding Net-New dependencies to dev-v2.X](#adding-net-new-dependencies-to-dev-2x)
- [Versioning Charets](#versioning-charts)
- [Upstream Charts](#upstream-charts)
- [Local Charts](#local-charts)
- [Rancher Version Annotations](#rancher-version-annotations)
- [Versioning FAQ](#versioning-faq)
- [Supporting Images in Airgap](#supporting-images-in-airgap)

---

### New Out Of Band Release Process
Starting on `17/May/2024`.

This is only valid for `prod-v2.*` branches.
Since this implementation, all teams may release each chart when they want.

##### Overview of the process:
1. Assuming you have a chart ready and merged on `dev-v2.*` branch.
2. On your local machine: `fetch`, `pull` and `checkout` to `prod-v2.*`
3. Create a new branch from `prod-v2.*`
4. Execute `make forward-port`
5. Clear your `release.yaml` file, leave only your chart that will be released
6. Add, Commit and push your changes to your forked repository

**Attention**: If you have a CRD that must be released with the chart, you should repeat `Step 4.` until `Step 6.` for the CRD chart.

7. Create a Pull Request from your forked repository to `rancher/charts` pointing to `prod-v2.*`


##### How to use `forward-port`:

**Usage:**

```(bash)
make forward-port CHART=<your_chart> VERSION=<version> BRANCH=<branch_to_pull_from> UPSTREAM=<git_remote>
```

Script Arguments Reference:
- CHART=`Chart name, exactly the same as in /charts and /assets folder`
- VERSION=`The version you want to release, the same one you would write into release.yaml`
- BRANCH=`The branch where the ready chart is merged in the remote repository`
- UPSTREAM=`The git remote name where the chart is present`


**Real-Example:**

```(bash)
make forward-port CHART=rancher-istio VERSION=103.3.0+up1.21.1 BRANCH=dev-v2.8 UPSTREAM=upstream
```

In this case, we are at branch `prod-v2.8`, we have a new version of Istio at `dev-v2.8`.

The script will get all necessary changes for `assets`, `charts`, `release.yaml` and `index.yaml` and handle them all automatically.

The changes will be pulled from the remote repository, the `UPSTREAM` variable tells which git remote the script must pull from, in my case I renamed it to upstream, the default value is `origin`.

```
❯ git remote -v
fork	https://github.com/nicholasSUSE/charts (fetch)
fork	https://github.com/nicholasSUSE/charts (push)
upstream	https://github.com/rancher/charts (fetch)
upstream	https://github.com/rancher/charts (push)

```

### Issues

All issues must be created in the [`rancher/rancher`](https://github.com/rancher/rancher) repository.

### Branches

- `dev-2.X` branches contain charts that are under active development, to be released in an upcoming Rancher release.
- `release-v2.X` branches contain charts that have already been developed, tested, and released on an existing Rancher release.

### Making Changes

Since this repository uses [`rancher/charts-build-scripts`](https://github.com/rancher/charts-build-scripts), making changes to this repository involves three steps:
1. Adding or modifying an existing `Package` tracked in the `packages/` directory. Usually involves `make prepare`, `make patch`, and `make clean`.
2. Running `make charts` to automatically generate assets used to serve a Helm repository (`charts/`, `assets/`, and `index.yaml`) based on the contents of `packages/`.
3. [CI] Running `make validate` to ensure that all generated assets are up-to-date and ready to be merged.


#### Adding Net-New dependencies to dev-2.x
A new build artifact was introduced in v2.7.0 of Rancher, titled `rancher-image-origins.txt`, which denotes the source code repository (github repository) of each image used in Charts and System-Charts.

When adding new dependencies to dev-2.7+, a PR must first be raised and merged in the Rancher repository with the required changes to the `pkg/image/origins.go` file.

This ensures that the artifact is up-to-date
with the latest images, and will prevent build failures within Rancher when attempting to generate the artifact. Changes to this file are **not** required when updating versions of existing dependencies.

#### Versioning Charts

Two kinds of charts exist in this repository. For each type the versioning is different.

- upstream charts
- local charts.

##### Upstream Charts

In this repository, all packages specify the `version` field in the `package.yaml`.

The upstream charts follow this versioning: `1.0.#+upX.Y.Z`

`X`.`Y`.`Z` is the upstream chart's `major`.`minor`.`patch`

The `1.0.#` versioning scheme roughly corresponds to the following rules (with exceptions):
- **Major Version**: represents the Rancher minor version these charts are being released to.
  - Anything less than `100`: Rancher 2.5
  - `100`: Rancher 2.6
  - `101` and `102`: Rancher 2.7
  - `103`: Rancher 2.8
  - `104`: Rancher 2.9
  - etc.
- **Minor Version**: represents a release line of a given chart within a Rancher minor version.
- **Patch Version**: represents a patch to a given release line of a chart within a Rancher minor version.


For more information on how package versioning works, please see [`docs/developing.md`](docs/developing.md).

##### Local Charts

- For local charts, we don't follow any complex versioning scheme. Only one `semver`, versioning scheme `x.x.x` is being followed.

#### Rancher Version Annotations

In addition to modifying the chart version, the `catalog.cattle.io/rancher-version` annotation is required for user-facing charts that show up in Rancher UI; there is no need to add the annotation to CRD charts or internal charts (like fleet).

General guidelines when releasing a new version of a user-facing chart:

1. **Ensure the chart has the annotation `catalog.cattle.io/rancher-version` with a lower and upper bound, such as `>= 2.6.0-0 < 2.7.0-0`**.

    - This indicates that a fresh install of the chart should be allowed in any version of Rancher over `2.6.0-0` and below `2.7.0-0` line.

    - It should be freshly installable in `2.6.0+`, but should not be freshly installable in Rancher `2.7.0+`. The lower bound is particularly useful for charts that will **not** work in an older version of Rancher, e.g. `catalog.cattle.io/rancher-version: >= 2.6.2-0 < 2.7.0-0` indicates that this chart should only be freshly installable in Rancher `2.6.2+`, but should not be freshly installable in `Rancher 2.7.0+`.
    - If you do this, it is also recommended that you **modify the previously released chart to have `catalog.cattle.io/rancher-version: < 2.6.2-0`**. For instructions on how to modify existing charts, see [`docs/developing.md`](docs/developing.md).
2. **Ensure the chart has the annotation `catalog.cattle.io/kube-version` with a lower and upper bound, such as `>= 1.16.0-0 < 1.25.0-0`**.
    - This indicates that a fresh install of the chart should be allowed in a cluster with any version of Kubernetes over `1.16.0` and below `1.25.0` line. It should be freshly installable in a `1.16.0+` cluster, but should not be freshly installable in `1.25.0+`.

#### Versioning FAQ

1. Do we directly backport charts to previous Rancher minor versions (e.g. make `100.x.x` available in Rancher `2.5`)?

    - No, we do not. If a fix needs to go to both Rancher `2.5` and `v2.6`, we just release a new chart in each branch. Then, we forward-port the one released in the `release-v2.5` branch to `release-v2.6`.

    - If a fix that went into Rancher `2.6` needs to be backported to Rancher `2.5`, it will be the developer's responsibility to bump the chart version in `dev-v2.5`, copy back the changes, and release a **new** chart following the Rancher `2.5` versioning scheme to `release-v2.5`.

2. If Rancher `2.5` releases Monitoring `14.5.100` and `16.6.0` and Rancher `2.6` releases Monitoring `100.0.0+up14.5.100` and `100.0.1+up16.6.0`, how do we prevent users from "downgrading" from `16.6.0` to `100.0.0+up14.5.100` on a `helm upgrade` after upgrading Rancher minor versions?

    - Currently, this is unavoidable. There is an expectation that users should look at the upstream annotation on the chart version (e.g. `+upX.Y.Z`), read the Rancher minor version release notes, or consult the chart's `README.md` or `app-README.md` before performing an upgrade on their applications after migrating to a new Rancher minor version.

    - We are still looking for a better way to mitigate this kind of risk.

3. For Rancher version annotations, why don't we need to add the lower bound all the time?

    - Each Rancher minor version has its dedicated chart release branch (e.g. `release-v2.5`, `release-v2.6`, etc.), so a chart designed for Rancher `2.6.x` will never be available or show up in Rancher `2.5.x`; therefore, we do not need to worry about setting a lower bound of `> 2.5.99-0` on all charts.

#### Supporting Images in Airgap

Currently, the scripts used to generate the `rancher-images.txt` (used for mirroring a private registry in a air-gapped Rancher setup) rely on `values.yaml` files in charts that nest all image repository and tags used by the Helm chart under `repository` and `tag` fields.

For example:

```yaml
image: org/repo:v0.0.0 # will not be picked up

hello:
  world:
    # will be picked up, even though it is nested under hello.world.*
    repository: org/repo
    tag: v0.0.0
    os: windows # optional, takes in a comma-delimited list of supported OSs. By default, the OS is assumed to be "linux" but you can specify "windows" or "linux,windows" as well.
```

Therefore, any charts that are committed into this repository must nest references to Docker images in this format within each chart's `values.yaml`; if an upstream chart you are referencing does not follow this format, it is recommended that you refactor the chart's values.yaml to look like this:

```yaml
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

#### Pull Request rules

Please create your Pull Request title following this rule:

```
[dev-v2.X] <chart> <version> <action>
[release-v2.X] <chart> <version> <action>
```

A working example:
```
[dev-v2.8] rancher-istio 103.2.0+up1.19.6 update
```

- `<chart>`: The full name of the charts exactly how it is written under `/charts folder`
- `<version>`: The full version of the chart, exactly how it is written under `release.yaml`
- `<action>`: `update`; `remove`; `add`

What you should keep in mind for releasing charts:

##### Basics
- Each Pull Request should only modify one chart with its dependencies.

##### release.yaml
- Each chart version in release.yaml DOES NOT modify an already released chart. If so, stop and modify the versions so that it releases a net-new chart.
- Each chart version in release.yaml IS exactly 1 more patch or minor version than the last released chart version. If not, stop and modify the versions so that it releases a net-new chart.

##### Chart.yaml and index.yaml
- The `index.yaml` file has an entry for your new chart version.
- The `index.yaml` entries for each chart matches the `Chart.yaml` for each chart.
- Each chart has ALL required annotations
  - kube-version annotation
  - rancher-version annotation
  - permits-os annotation (indicates Windows and/or Linux)
