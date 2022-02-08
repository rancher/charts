# Developing the rancher-istio chart

### Repos used for entire Dev process:
https://github.com/rancher/charts/tree/dev-v2.6/packages/rancher-istio
https://github.com/rancher/istio-installer
https://github.com/rancher/image-mirror

### Additional Resources
https://istio.io/latest/
https://github.com/istio/istio
https://slack.istio.io/
https://istio.io/latest/blog/feed.xml - setup RSS Feed, to get automatic updates

### Things you should read before developing rancher-istio
https://istio.io/latest/about/faq/
https://istio.io/latest/docs/ops/deployment/architecture/
https://istio.io/latest/docs/concepts/

## Summary of Istio Chart Architecture

The rancher-istio chart uses a docker image (https://github.com/rancher/istio-installer) to run `istioctl` commands to create and mange the Istio control plane and its resources. The decision to use `istioctl` commands wrapped in a docker image was made at a time where upstream Istio had decided to no longer support helm chart,s and had not made the IstioOperator standalone production ready. `istioctl` uses the IstioOperator custom resource to determine what to deploy. Note: You can pass multiple IstioOperator custom resources to the Istio operator in an `istioctl` command and they will get applied in the order that they are passed in, which is how the Overlay file functions.


## Getting Started with a Basic Rancher-Istio change

#### Example PR for Istio, Kiali, and Jaeger upgrades
https://github.com/rancher/charts/pull/1578

#### Steps to Follow

1. See the announcement of the new Istio version https://istio.io/latest/news/
2. Check the release notes to see if there are any significant changes that would cause us to need an upgrade. We do not update our chart for every version of Istio that is published but that determination is up to you. We are wanting to move to a place where we can have a rancher-istio chart version for each new Istio version, but we aren't there yet. 
3. If the changes seem significant or there are features we would like to make available, open an issue for the new Istio version. Note: We want at least one rancher-istio chart for every version of Istio due to upstream Istio upgrade requirements
4. https://kiali.io/docs/installation/installation-guide/prerequisites/#istio-version-compatibility check to see if we will need a new version of Kiali as well. Open an issue to track the Kiali version upgrade. 
5. Check to see if we will need a new version of Jaeger tracing (this is generally based on k8s version compatibility so use your best judgement again on features / bug fixes / security changes). Open an issue to track the Jaeger version upgrade
6. To see what changes we need to make to our chart, we generally check to see if there are changes to the IstioOperator custom resource. This can be done by downloading the version of `istioctl` that we are upgrading to and running `istioctl profile dump demo` or by going to https://github.com/istio/istio/blob/master/manifests/profiles/demo.yaml (you want to make sure you are going to the demo.yaml for the version of Istio that you are upgrading to, so it wont always be master). Then compare the demo profile for the version we are upgrading to, side by side with the istio-base.yaml https://github.com/rancher/charts/blob/dev-v2.6/packages/rancher-istio/rancher-istio/charts/configs/istio-base.yaml and make changes to the istio-base.yaml where needed. We generally want to keep the istio-base.yaml file minimal (i.e only what is necessary for a basic install), so don't add anything unless its explicitely to change a default value or needs added based on the change notes from the Istio release. If there are changes, make those changes to the rancher-istio chart.
7. You also need to bump the tag versions in the values.yaml from the old Istio version to the new version that ew are upgrading to https://github.com/rancher/charts/blob/dev-v2.6/packages/rancher-istio/rancher-istio/charts/values.yaml
8. You also want to see if the Istio change notes have any changes relating to the `istioctl` commands. Validate that the changes to `istioctl` doesn't affect https://github.com/rancher/istio-installer/blob/master/scripts/create_istio_system.sh or https://github.com/rancher/istio-installer/blob/master/scripts/uninstall_istio_system.sh. If it does, make sure the update the docker image scripts accordingly.
9. You also need to update the istio-installer image version https://github.com/rancher/istio-installer/blob/e3ace32aecbfbe5b0426770ae33747751c42d8a9/Dockerfile#L2 to match the new version of Istio, as well as add the version here https://github.com/rancher/istio-installer/blob/e3ace32aecbfbe5b0426770ae33747751c42d8a9/scripts/fetch_istio_releases.sh#L9 - more detailed instructions can be found here https://github.com/rancher/istio-installer/blob/master/README.md
10. After merging a tagging a new version of the istio-installer, upgrade the image version in the https://github.com/rancher/charts/blob/502035b9ac9763e2ebbdde5c05f2137862bb2678/packages/rancher-istio/rancher-istio/charts/values.yaml#L7 values yaml.
11. Bump the rancher-istio chart version
11. Update Kiali and Jaeger, if needed, prior to running `make prepare`

These are basic steps on how to make changes to the rancher-istio chart. Most of the changes will occur in the istio-base.yaml, the values.yaml and in the istio-installer. There are test cases to follow in the https://github.com/rancher/istio-installer#readme

Open Upstream Issues related to rancher-istio issue
https://github.com/istio/istio/issues/36526
https://github.com/kiali/kiali/issues/4459
https://github.com/istio/istio/issues/26234

