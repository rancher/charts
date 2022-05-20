## Rancher Charts

This repository contains Helm charts served by Rancher Apps & Marketplace.

### Branches

- `dev-2.X` branches contain charts that under active development, to be released in an upcoming Rancher release.
- `release-v2.X` branches contain charts that have already been developed, tested, and released on an existing Rancher release.

### Making Changes

Since this repository uses [`rancher/charts-build-scripts`](https://github.com/rancher/charts-build-scripts), making changes to this repository involves three steps:
1. Adding or modifying an existing `Package` tracked in the `packages/` directory. Usually involves `make prepare`, `make patch`, and `make clean`.
2. Running `make charts` to automatically generate assets used to serve a Helm repository (`charts/`, `assets/`, and `index.yaml`) based on the contents of `packages/`.
3. [CI] Running `make validate` to ensure that all generated assets are up-to-date and ready to be merged.

A first attempt was made to automate these steps for url only based charts, in the following way (example with rancher-backup chart values):

1. Remove existing chart(s): `CHARTS=rancher-backup/rancher-backup,rancher-backup/rancher-backup-crd ./scripts/remove-chart-version-if-exists`
2. Commit changes (git add/git commit)
3. Add new chart(s): `TEMPLATE_BASE_URL=https://raw.githubusercontent.com/rancher/your_chart CHARTS=rancher-backup/rancher-backup,rancher-backup/rancher-backup-crd TEMPLATE_VALUES='VERSION=2.1.3-rc1' ./scripts/add-chart-version`, the `TEMPLATE_BASE_URL` will be used to retrieve the template `package.yaml` and the `TEMPLATE_VALUES` will be replaced in that template. In this example, the template files should be present at `https://raw.githubusercontent.com/rancher/your_chart/rancher-backup.tmpl` and `https://raw.githubusercontent.com/rancher/your_chart/rancher-backup-crd.tmpl`.
4. Commit changes (git add/git commit)
5. Run make charts: `CHARTS=rancher-backup/rancher-backup,rancher-backup/rancher-backup-crd VERSION=2.1.3-rc1 ./scripts/make-charts`
6. Commit changes (git add/git commit)

#### Versioning Charts

In this repository, all packages specify the `version` field in the `package.yaml`.

The versioning scheme roughly corresponds to the following rules (with exceptions):
- Major Version: represents the Rancher minor version these charts are being released to.
  - Anything less than `100`: Rancher 2.5
  - `100`: Rancher 2.6
  - `101`: Rancher 2.7
  - etc.
- Minor Version: represents a release line of a given chart within a Rancher minor version.
- Patch Version: represents a patch to a given release line of a chart within a Rancher minor version.

As a rule of thumb, you will only ever touch this version to **increment the patch version once per Rancher patch release**. Once it has been incremented, it should not be incremented again until the next Rancher patch release, even if the chart points to an upstream that has been modified.

For more information on how package versioning works, please see [`docs/developing.md`](docs/developing.md).

#### Rancher Version Annotations

In addition to modifying the chart version, the `catalog.cattle.io/rancher-version` annotation is required for user-facing charts which show up in Rancher UI; there is no need to add the annotation to CRD charts or internal charts (like fleet).

General guidelines when releasing a new version of a user-facing chart:

1. **Ensure the chart has the annotation `catalog.cattle.io/rancher-version` with an upper bound, such as `< 2.6.99-0`**. This indicates that a fresh install of the chart should be allowed in any version of Rancher at or below `2.6.99-0` line, but should not be freshly installable in Rancher `2.7.0+`.
2. If and only if a chart will **not** work in an older version of Rancher, you will need to **amend this annotation to also include a lower bound like `>= 2.6.2-0`**. e.g. `catalog.cattle.io/rancher-version: >= 2.6.2-0 < 2.6.99-0` indicates that this chart should only be freshly installable in Rancher `2.6.2+`, but should not be freshmy installable in `Rancher 2.7.0+`.
  - If you do this, it is also recommended that you **modify the previously released chart to have `catalog.cattle.io/rancher-version: < 2.6.2-0`**. For instructions on how to modify existing charts, see [`docs/developing.md`](docs/developing.md).

#### Versioning FAQ

- Do we directly backport charts to previous Rancher minor versions (e.g. make `100.x.x` available in Rancher `2.5`)?

No, we do not. If a fix needs to go to both Rancher `2.5` and `v2.6`, we just release a new chart in each branch. Then, we forward-port the one released in the `release-v2.5` branch to `release-v2.6`.

If a fix that went into Rancher `2.6` needs to be backported to Rancher `2.5`, it will be the developer's responsibility to bump the chart version in `dev-v2.5`, copy back the changes, and release a **new** chart following the Rancher `2.5` versioning scheme to `release-v2.5`.

- If Rancher `2.5` releases Monitoring `14.5.100` and `16.6.0` and Rancher `2.6` releases Monitoring `100.0.0+up14.5.100` and `100.0.1+up16.6.0`, how do we prevent users from "downgrading" from `16.6.0` to `100.0.0+up14.5.100` on a `helm upgrade` after upgrading Rancher minor versions?

Currently, this is unavoidable. There is an expectation that users should look at the upstream annotation on the chart version (e.g. `+upX.Y.Z`), read the Rancher minor version release notes, or consult the chart's `README.md` or `app-README.md` before performing an upgrade on their applications after migrating to a new Rancher minor version.

We are still looking for a better way to mitigate this kind of risk.

- For Rancher version annotations, why we don't we need to add the lower bound all the time?

Each Rancher minor version has its dedicated chart release branch (e.g. `release-v2.5`, `release-v2.6`, etc.), so a chart designed for Rancher `2.6.x` will never be available or show up in Rancher `2.5.x`; therefore, we do not need to worry about setting a lower bound of `> 2.5.99-0` on all charts.

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

### Links

For more information on how to make changes to this repository, please see [`docs/developing.md`](docs/developing.md).

For more information on experimental features, please see [`docs/experimental.md`](docs/experimental.md).

For more information on commands that can be run in this repository, please see [`docs/makefile.md`](docs/makefile.md).

For more information on `Packages`, please see [`docs/packages.md`](docs/packages.md).

For more information on CI, please see [`docs/validation.md`](docs/validation.md).
