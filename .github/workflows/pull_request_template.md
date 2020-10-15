#### Pull Request Checklist ####

**Note: This checklist is only applicable to charts that are being added to the new `Apps & Marketplace` UI.**

One of the following must be checkmarked:

- [ ] Chart has never been pushed to https://github.com/rancher/charts/tree/main-source.

- [ ] If your chart is forked from an upstream repository, ensure that the `packageVersion` specified is at least one version higher than the `packageVersion` of your chart in https://github.com/rancher/charts/tree/main/assets to avoid overwriting the existing chart archive.

- [ ] If your chart is a Rancher original chart maintained in `rancher/charts`, ensure that the chart version in the `Chart.yaml` is at least one version higher than the version of your chart in https://github.com/rancher/charts/tree/main/assets to avoid overwriting the existing chart archive.

#### Types of Change ####

<!-- New image, version bump. script update, etc etc -->

#### Linked Issues ####

<!-- Link any related issues, pull-requests, or commit hashes that are relevant to this pull request.  -->

#### Additional Notes ####

<!-- Any additional details / test results / etc -->
