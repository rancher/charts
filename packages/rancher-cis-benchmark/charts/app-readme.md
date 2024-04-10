# Rancher CIS Benchmarks

This chart enables security scanning of the cluster using [CIS (Center for Internet Security) benchmarks](https://www.cisecurity.org/benchmark/kubernetes/).

For more information on how to use the feature, refer to our [docs](https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/cis-scan-guides).

This chart installs the following components:

- [cis-operator](https://github.com/rancher/cis-operator) - The cis-operator handles launching the [kube-bench](https://github.com/aquasecurity/kube-bench) tool that runs a suite of CIS tests on the nodes of your Kubernetes cluster. After scans finish, the cis-operator generates a compliance report that can be downloaded.
- Scans - A scan is a CRD (`ClusterScan`) that defines when to trigger CIS scans on the cluster based on the defined profile. A report is created after the scan is completed.
- Profiles - A profile is a CRD (`ClusterScanProfile`) that defines the configuration for the CIS scan, which is the benchmark versions to use and any specific tests to skip in that benchmark. This chart installs a few default `ClusterScanProfile` custom resources with no skipped tests, which can immediately be used to launch CIS scans.
- Benchmark Versions - A benchmark version is a CRD (`ClusterScanBenchmark`) that defines the CIS benchmark version to run using kube-bench as well as the valid configuration parameters for that benchmark. This chart installs a few default `ClusterScanBenchmark` custom resources.
- Alerting Resources - Rancher's CIS Benchmark application lets you run a cluster scan on a schedule, and send alerts when scans finish.
    - If you want to enable alerts to be delivered when a cluster scan completes, you need to ensure that [Rancher's Monitoring and Alerting](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/) application is pre-installed and the [Receivers and Routes](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/configuration/#alertmanager-config) are configured to send out alerts.
    - Additionally, you need to set `alerts: true` in the Values YAML while installing or upgrading this chart.

## CIS Kubernetes Benchmark support

| Source | Kubernetes distribution | scan profile                                                                                                       | Kubernetes versions |
|--------|-------------------------|--------------------------------------------------------------------------------------------------------------------|---------------------|
| CIS    | any                     | [cis-1.7](https://github.com/rancher/security-scan/tree/master/package/cfg/cis-1.7)                                | v1.25               |
| CIS    | any                     | [cis-1.8](https://github.com/rancher/security-scan/tree/master/package/cfg/cis-1.8)                                | v1.26+              |
| CIS    | rke                     | [rke-cis-1.7-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/rke-cis-1.7-permissive)  | rke1-v1.25          |
| CIS    | rke                     | [rke-cis-1.7-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/rke-cis-1.7-hardened)      | rke1-v1.25          |
| CIS    | rke                     | [rke-cis-1.8-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/rke-cis-1.8-permissive)  | rke1-v1.26+         |
| CIS    | rke                     | [rke-cis-1.8-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/rke-cis-1.8-hardened)      | rke1-v1.26+         |
| CIS    | rke2                    | [rke2-cis-1.7-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/rke2-cis-1.7-permissive)| rke2-v1.25          |
| CIS    | rke2                    | [rke2-cis-1.7-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/rke2-cis-1.7-hardened)    | rke2-v1.25          |
| CIS    | rke2                    | [rke2-cis-1.8-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/rke2-cis-1.8-permissive)| rke2-v1.26+         |
| CIS    | rke2                    | [rke2-cis-1.8-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/rke2-cis-1.8-hardened)    | rke2-v1.26+         |
| CIS    | k3s                     | [k3s-cis-1.7-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/k3s-cis-1.7-permissive)  | k3s-v1.25           |
| CIS    | k3s                     | [k3s-cis-1.7-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/k3s-cis-1.7-hardened)      | k3s-v1.25           |
| CIS    | k3s                     | [k3s-cis-1.8-permissive](https://github.com/rancher/security-scan/tree/master/package/cfg/k3s-cis-1.8-permissive)  | k3s-v1.26+          |
| CIS    | k3s                     | [k3s-cis-1.8-hardened](https://github.com/rancher/security-scan/tree/master/package/cfg/k3s-cis-1.8-hardened)      | k3s-v1.26+          |
| CIS    | eks                     | eks-1.2.0                                                                                                          | eks                 |
| CIS    | aks                     | aks-1.0                                                                                                            | aks                 |
| CIS    | gke                     | gke-1.2.0                                                                                                          | gke                 |

## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API.

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.

> **Note:**
> In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.

> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.

Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.

As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.
