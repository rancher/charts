## Packages

### What is a Package?

A Package represents a grouping of one or more Helm Charts. It is declared within `packages/<package>/package.yaml` with the following spec:

```text
packageVersion: 00
releaseCandidateVersion: 00
workingDir: # The directory within your package that will contain your working copy of the chart (e.g. charts)
url: # A URL pointing to an UpstreamConfiguration
subdirectory: # Optional field for a specific subdirectory for all upstreams
commit: # Optional field for a specific commit if your URL point to a Github Repository
additionalCharts:
# These contain other charts that you would like to package alongside this chart
- workingDir: # same as above
  upstreamOptions:
    # Mutually exclusive with crdOptions
    url: # same as above
    subdirectory: # optional, same as above
    commit: # optional, same as above
  crdOptions:
    # Mutually exclusive with upstreamOptions
    templateDirectory: # A directory within packages/<package>/template that will contain a template for your CRD chart
    crdDirectory: # Where to place your CRDs within a CRD chart (e.g. crds for default charts)
    addCRDValidationToMainChart: # Whether to add additional validation to your main chart to check that the CRD chart is installed.
```

As seen in the spec above, every Package must have exactly one Chart designated as a main Chart (multiple main Charts are not supported at this time) and all other Charts will be considered AdditionalCharts.

#### UpstreamOptions

Charts or AdditionalCharts can provide UpstreamOptions with the following possible configurations:
- Chart Archive: provide the `url` and optionally `subdirectory`
- Github Repository: provide the `url` (e.g. `https://github.com/rancher/charts-build-scripts.git`) and optionally a `subdirectory` and a `commit`
- Package: provide a `url: packages/<package>` and the main Chart from that package can be pulled. You should ensure that a loop is not introduced.
- Local: provide `url: local` and the package will assume the contents of `workingDir` are exactly the chart you want to use.

#### [AdditionalCharts] CRDOptions

AdditionalCharts can provide CRDOptions instead of UpstreamOptions. These CRDOptions allow the scripts to automatically construct a CRD chart from your main Chart's contents based on the template provided.

A CRD Chart is a Helm Chart whose sole purpose is to install CRDs onto a cluster before the main Chart is installed.

You should not need a CRD chart if your main chart has the following qualities:
1) Your main chart does not install any CRDs.
2) Even if your main chart installs CRDs, it never installs resources of that kind as part of the release. In this case, CRDs can just remain in your `templates/` directory to be managed by Helm.
3) Neither option from above applies to you, but you do not need to facilitate automatically upgrading CRDs or providing a way for a user to cleanly delete CRDs via a second Helm release. In this case, the current Helm feature of having your CRDs placed in the `crds/` directory should work for you.

### Directory Structure

```text
packages/
  <package>/
    package.yaml # A file that represents your package's overall configuration
    rebase.yaml # Optional, allows you to see the drift between your current upstream and another upstream
    generated-changes/
      additional-charts/
        # Contains one directory per additional chart, keeping track of its dependencies and patches
        <additionalChart>/
          generated-changes/
            # Same as above, but no more additionalCharts
      dependencies/
        # Contains one directory per dependency.
        <dependency>
          dependency.yaml # The UpstreamConfiguration of a particular dependency
      exclude/
        # Files that were excluded from upstream verbatim. Follows the same directory structure as the chart
      overlay/
        # Files that were overlaid onto upstream verbatim. Follows the same directory structure as the chart
      patch/
        # Files that were patches from upstream. Follows the same directory structure as the chart and contains Unified Unix Diffs
    templates/ 
      # Contains any templates. Currently only used by CRDOptions
```

### Developer Workflow

Developers will use the following commands to work with packages:

- `make prepare`: Pulls in your charts from upstream and creates a basic `generated-changes/` directory with your dependencies from upstream

- `make patch`: Updates your `generated-changes/` to reflect the difference between upstream and the current working directory of your branch. Requires prepare

- `make charts`: Runs prepare and then exports your charts to `assets/` and `charts/` and generates or updates your `index.yaml`. Can be used for testing; a Rancher Helm Repository that points to a branch that has these directories with the `index.yaml` should be able to find and deploy working copies of your chart.

- `make clean`: Cleans up all the working directories of charts to get your repository ready for a PR

To update your working copy of the charts-build-scripts after rebasing against upstream, run:

- `make pull-scripts`: Pulls in the version of the `charts-build-scripts` indicated in scripts

To check whether the new packages you are introducing will cause any issues with upstream that you will synchronize with, run:

- `make validate`: Validates your current repository branch against all the repository branches indicated in your configuration.yaml

#### Common Workflow

- Make or update the `packages/<package>/package.yaml to point to your upstream and set any other chart options
  - Note: never update your upstream after generating changes. `make pull-scripts; ./bin/charts-build-scripts rebase` (experimental) can assist you in figuring out what patches you need to make to rebase to a new upstream Chart by simply placing the new upstream's UpstreamConfiguration in a `rebase.yaml` file rooted at your package's directory and running the script. It will then generate a `generated-changes/rebase/` directory that contains `overlay`, `exclude`, and `patch`, files describing the difference between your current upstream and the new upstream without your changes included in any way. Once you make the necessary changes in an already prepared Chart, replace the `package.yaml` UpstreamConfiguration with your `rebase.yaml` UpstreamConfiguration and see whether the `generated-changes` are appropriately modified
- Run `PACKAGE=<package> make prepare` to pull in your upstream repositories
  - Note: On a prepare, the charts-build-scripts will automatically replace your charts existing dependencies with dependencies that will show up in `generated-changes/dependencies/<dependency>/dependency.yaml`. Since the spec of this file follows the `UpstreamConfiguration` described above, you can modify this to point your dependencies to a local chart (rooted at `generated-changes/dependencies/<dependency>/`), another package (`make validate` and `make sync` automatically take care of any packageVersion / releasedCandidateVersion dependencies that could be introduced by this), a Chart archive (e.g. point it to a newer version of the dependency), or a Github Repository (at a subdirectory / commit).
  - Note: As part of replacing your dependencies, the Chart.yaml and requirements.yaml are considered "Managed Files". These files are prone to having conflicts and may need to be deleted / recreated on a prepare if there are conflicts. Please open up an issue if you encounter frequent bugs with these files so that we can take a look.
- Make changes to the relevant working directories
- Run `PACKAGE=<package> make patch` to save your changes
- Run `make charts` to test your changes by committing the generated directories and pushing it to a branch. Once it is available at such a branch, it can be picked up by any tools that can point to Github based Helm Repositories (e.g. Rancher Cluster Explorer Apps & Marketplace).
- Repeat above steps if you encounter bugs, otherwise continue.
- Remove the commit with your newly generated resources (`assets/`, `charts/` and `index.yaml`) and remove the resources themselves manually
- Run `make clean`
- Commit your changes and push them to another branch to get ready for a PR
- Run `make validate` to ensure that your current repository wouldn't introduce any conflicts on a sync. This step can be skipped if a Github Workflow already checks for this on a PR push
- Open up a PR with your changes

### Troubleshooting

Open up an issue on [https://github.com/rancher/charts-built-scripts](https://github.com/rancher/charts-built-scripts)

### Maintainers
- aiyengar2 (arvind.iyengar@rancher.com)
