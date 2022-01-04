## Packages

### What is a Package?

A Package represents a grouping of one or more Helm Charts. It is declared within `packages/<package>/package.yaml` with the following spec:

```text
version: # The version of the generated chart. This value will override the upstream chart's version. Mutually exclusive with packageVersion
packageVersion: 1 # The value range is from 1 to 99. Mutually exclusive with version
workingDir: # The directory within your package that will contain your working copy of the chart (e.g. charts)
url: # A URL pointing to an UpstreamConfiguration
subdirectory: # Optional field for a specific subdirectory for all upstreams
commit: # Optional field for a specific commit if your URL point to a Github Repository
doNotRelease: # Optional field to specify that this chart should not produce any generated changes on running `make charts`.
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

