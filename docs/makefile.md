## Makefile

### Basic Commands

`make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts.

### Package Commands

`make prepare`: Pulls in your charts from upstream and creates a basic `generated-changes/` directory with your dependencies from upstream. By default, this prepares every `Package` in your repository but it can be scoped by providing `PACKAGE=<packagePrefix>`, where `packagePrefix` can either be 1) the exact folder in which a `package.yaml` resides in `packages/` or 2) a directory that contains multiple directories with `package.yaml` files; in the latter case, all packages in that prefix will be prepared. *If you are working with a local chart with no dependencies, this command does nothing.*

`make patch`: Updates your `generated-changes/` to reflect the difference between upstream and the current working directory of your branch (note: this command should only be run after `make prepare`). Unlike `make prepare`, `PACKAGE=<packagePrefix>` must point to an exact folder in which a `package.yaml` resides in `packages/`. *If you are working with a local chart with no dependencies, this command does nothing.*

`make clean`: Cleans up all the working directories of charts to get your repository ready for a PR. Supports `PACKAGE=<packagePrefix>` as defined above. *If you are working with a local chart with no dependencies, this command does nothing.*

`make charts`: Runs `make prepare` and then exports your charts to `assets/` and `charts/` and generates or updates your `index.yaml`. Supports `PACKAGE=<packagePrefix>` as defined above. 

Please see [`docs/developing.md`](docs/developing.md) for more information on how to use these commands in a normal developer workflow.

### Assets, Chart, and Index Commands

`make index`: Reconstructs the `index.yaml` based on the existing charts. Used by `make charts` and `make validate` under the hood.

`make remove`: Removes the asset and chart associated with a provided chart version. Performs the equivalent of an `rm -rf` on the provided `CHART=<chart>` and `VERSION=<version>` entries and runs `make index`.

`make zip`: Reconstructs archives in the `assets` directory based on the current contents in `charts` and updates the `charts/` contents based on the packaged archive(s). Can be scoped to specific charts via specifying `CHART={chart}` or `CHART={chart}/{version}`. Runs `make index` after reconstruction.

Please see [`docs/developing.md`](docs/developing.md) for more information on how to use these commands to modify released charts.

### CI Commands

`make validate`: Checks whether all generated assets used to serve a Helm repository (`charts/`, `assets/`, and `index.yaml`) are up-to-date. If `validate.url` and `validate.branch` are provided in the configuration.yaml, it will also ensure that any additional changes introduced only modify chart or package versions specified in the `release.yaml`; otherwise it will output the expected `release.yaml` based on assets it detected changes in.

Please see [`docs/validation.md`](docs/validation.md) for more information on how CI is performed.

### Docs and Scripts Commands

`make template`: Updates the current directory by applying the configuration.yaml on [upstream Go templates](https://github.com/rancher/charts-build-scripts/tree/master/templates/template) to pull in the most up-to-date docs, scripts, etc. from [rancher/charts-build-scripts](https://github.com/rancher/charts-build-scripts).

### Advanced and Misc. Commands

`make list`: Prints the list of all packages tracked in the current repository and recognized by the scripts. `export PORCELAIN=1` allows you to specify that the output of this command should be script-friendly.

`make unzip`: Reconstructs all charts in the `charts` directory based on the current contents in `assets`. Can be scoped to specific charts via specifying `ASSET=<asset>` or `ASSET=<asset}>/<chart>-<version>.tgz`. Runs `make index` after reconstruction.

`make standardize`: Takes an arbitrary Helm repository (defined as any repository with a set of Helm charts under `charts/`) and standardizes it to the expected repository structure of these scripts.

`make clean-cache`: Deletes `.charts-build-scripts/.cache`. Only used if `export USE_CACHE=1` is set, which indicates that you are using the experimental caching feature introduced in v0.3.0 of the scripts. Please see [`docs/experimental.md`](docs/experimental.md) for more information.