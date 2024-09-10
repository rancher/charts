### Run-Time Protection Without Compromise

NeuVector delivers a complete run-time security solution with container process/file system protection and vulnerability scanning combined with the only true Layer 7 container firewall. Protect sensitive data with a complete container security platform.

NeuVector integrates tightly with Rancher and Kubernetes to extend the built-in security features for applications that require defense in depth. Security features include:

+ Build phase vulnerability scanning with Jenkins plug-in and registry scanning
+ Admission control to prevent vulnerable or unauthorized image deployments using Kubernetes admission control webhooks
+ Complete run-time scanning with network, process, and file system monitoring and protection
+ The industry's only layer 7 container firewall for multi-protocol threat detection and automated segmentation
+ Advanced network controls including DLP detection, service mesh integration, connection blocking and packet captures
+ Run-time vulnerability scanning and CIS benchmarks

Additional Notes:
+ Previous deployments from Rancher, such as from our Partners chart repository or the primary NeuVector Helm chart, must be completely removed in order to update to the new integrated feature chart. See https://github.com/rancher/rancher/issues/37447.
+ Container runtime and runtime path are auto detected in NeuVector 5.3.0 version. If the socket path is not at the default location, use runtimePath in values.yaml to specify the location.
+ For deploying on hardened RKE2 and K3s clusters, enable PSP and set user id from other configuration for Manager, Scanner and Updater deployments. User id can be any number other than 0.
+ For deploying on hardened RKE cluster, enable PSP from security settings.

## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API.

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.
 **Note:**
 In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.

 **Note:**
 If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**

 If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.

Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.

As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.
