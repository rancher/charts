## Experimental: Caching

If you specify `export USE_CACHE=1` before running the scripts, a cache will be used that is located at `.charts-build-scripts/.cache`. This cache is only used on `make prepare`, `make patch`, and `make charts`; it is intentionally disabled on `make validate`.

This cache will be used to store references to anything that is pulled into the scripts (e.g. anything defined via `UpstreamOptions`, such as your upstream charts). If used, the speed of the above three commands may dramatically increase since it is no longer relying on making a network call to pull in your charts from the given cached upstream.

However, currently caching is only implemented for `UpstreamOptions` that point to a GitHub Repository at a particular commit, since that is an immutable reference (e.g. any amends to that commit would result in a brand-new commit hash).

If you would like to clean up your cache, either delete the `.charts-build-scripts/.cache` directory or run `make clean-cache`.

## Experimental: Using Manifest Upstreams (Instead of Helm Charts)

If your package.yaml points to an upstream that does not declare a Chart.yaml, the default behavior of the scripts is as follows:
1) Move all YAML files to `templates`
2) Create a dummy, hard-coded `Chart.yaml`:

```yaml
apiVersion: v2
appVersion: 0.1.0
description: A Helm chart for Kubernetes
name: my-helm-chart
type: application
version: 0.1.0
```

This will be applied on the upstream chart before applying `make patch`, which means that the `generated-changes/patch/Chart.yaml.patch` represents changes you introduce on top of this dummy, hard-coded `Chart.yaml`. As a result, you can proceed to make changes such as adding dependencies, adding annotations, etc.

Note: This feature is marked as experimental since it's unclear if there are any additional requirements necessary to support edge cases around pulling upstream manifests. Please open up an issue on [https://github.com/rancher/charts-build-scripts](https://github.com/rancher/charts-build-scripts) if you have any suggestions!

## Experimental: Performing only local or upstream validation

In order to make it easier to debug issues related to a failure in `make validate`, two command-line flags were introduced.

If you would like to perform local validation only (e.g. checking if `make charts` produces no changes), you can run `./bin/charts-build-scripts validate --local`.

If you would like to perform remote validation only (e.g. checking if all differences between your current repository and an upstream repository are tracked in the `release.yaml`), you can run `./bin/charts-build-scripts validate --upstream`.

Note: These options have **not** been exposed as environment variables since an average consumer of the scripts should rarely, if at all, have any reason for using these options.