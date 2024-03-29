# Rancher Istio

Our [Istio](https://istio.io/) installer wraps the istioctl binary commands in a handy helm chart, including an overlay file option to allow complex customization. It also includes:
* **[Kiali](https://kiali.io/)**: Used for graphing traffic flow throughout the mesh
* **[Jaeger](https://www.jaegertracing.io/)**: A quick start, all-in-one installation used for tracing distributed system. This is not production qualified, please refer to jaeger documentation to determine which installation you may need instead.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/istio/v2.5/).
## Warnings
- Upgrading across more than two minor versions (e.g., 1.6.x to 1.9.x) in one step is not officially tested or recommended. See [Istio upgrade docs](https://istio.io/latest/docs/setup/upgrade/) for more details.

## Known Issues

#### Airgapped Environments
**A temporary fix has been added to this chart to allow upgrades to succeed in an airgapped environment. See [this issue](https://github.com/rancher/rancher/issues/30842) for details.** We are still advocating for an upstream fix in Istio to formally resolve this issue. The root cause is the Istio Operator upgrade command reaches out to an external repo on upgrades and the external repo is not configurable. We are tracking the fix for this issue [here](https://github.com/rancher/rancher/issues/33402)

#### Installing Istio with CNI component enabled on RHEL 8.4 SElinux enabled cluster.
To install istio with CNI enabled, e.g. when cluster has a default PSP set to "restricted", on a cluster using nodes with RHEL 8.4 SElinux enabled, run the following command on each cluster node before creating a cluster.
`mkdir -p /var/run/istio-cni && semanage fcontext -a -t container_file_t /var/run/istio-cni && restorecon -v /var/run/istio-cni`
See [this issue](https://github.com/rancher/rancher/issues/33291) for details.

## Installing istio with distroless-images.
Istio `100.5.0+up1.15.3` uses distroless images for `istio-proxyv2`, `istio-install-cni` and `istio-pilot`. Distroless images don't have the common debugging tools like `bash`, `curl`, etc. If you wish to troubleshoot Istio, you can switch to regular images by updating `values.yaml` file. 

## Deprecations

#### v1alpha1 security policies
As of 1.6, Istio removed support for `v1alpha1` security policies resource and replaced the API with `v1beta1` authorization policies. https://istio.io/latest/docs/reference/config/security/authorization-policy/

If you are currently running rancher-istio <= 1.7.x, you need to migrate any existing `v1alpha1` security policies to `v1beta1` authorization policies prior to upgrading to the next minor version.

> **Note:** If you attempt to upgrade prior to migrating your policy resources, you might see errors similar to:
```
Error: found 6 CRD of unsupported v1alpha1 security policy
```
```
 Error: found 1 unsupported v1alpha1 security policy
 ```
 ```
 Control Plane - policy pod - istio-policy - version: x.x.x does not match the target version x.x.x
 ```
 Continue with the migration steps below before retrying the upgrade process.

#### Migrating Resources:
Migration steps can be found in this [istio blog post](https://istio.io/latest/blog/2021/migrate-alpha-policy/ "istio blog post").

You can also use these [quick steps](https://github.com/rancher/rancher/issues/34699#issuecomment-921995917 "quick steps") to determine if you need to follow the more extensive migration steps.
