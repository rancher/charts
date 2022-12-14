# Epinio PaaS

Opinionated platform that runs on Kubernetes to take you from Code to URL in one step.

__Attention__:

  - Requires `cert-manager` as dependency.
  - Requires `helm-controller` as dependency.

__Warning__:

  - The bugfix https://github.com/epinio/epinio/pull/1836 for `app export` has
    failed to make it into the Marketplace integration due to issues with
    mirroring the `skopeo/stable` image for Rancher. The functionality from
    before the fix is still available, however it will error at the end, when
    trying to export the image.
