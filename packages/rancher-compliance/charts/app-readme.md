
# Rancher Compliance

This chart enables security scanning of the cluster using custom benchmark profiles.

For more information on how to use the feature, refer to our [docs](https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/compliance-scan-guides).

This chart installs the following components:

- [compliance-operator](https://github.com/rancher/compliance-operator) - The compliance-operator handles launching the [kube-bench](https://github.com/aquasecurity/kube-bench) tool that runs a suite of security scans on the nodes of your Kubernetes cluster. After scans finish, the compliance-operator generates a compliance report that can be downloaded.
- Scans - A scan is a CRD (`ClusterScan`) that defines when to trigger scans on the cluster based on the defined profile. A report is created after the scan is completed.
- Profiles - A profile is a CRD (`ClusterScanProfile`) that defines the configuration for the scan, which is the benchmark versions to use and any specific tests to skip in that benchmark. This chart installs a few default `ClusterScanProfile` custom resources with no skipped tests, which can immediately be used to launch scans.
- Benchmark Versions - A benchmark version is a CRD (`ClusterScanBenchmark`) that defines the benchmark version to run using kube-bench as well as the valid configuration parameters for that benchmark. This chart installs a few default `ClusterScanBenchmark` custom resources.
- Alerting Resources - Rancher's Compliance application lets you run a cluster scan on a schedule, and send alerts when scans finish.
    - If you want to enable alerts to be delivered when a cluster scan completes, you need to ensure that [Rancher's Monitoring and Alerting](https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/monitoring-alerting-guides) application is pre-installed and the [Receivers and Routes](https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/monitoring-v2-configuration-guides/advanced-configuration/alertmanager) are configured to send out alerts.
    - Additionally, you need to set `alerts: true` in the Values YAML while installing or upgrading this chart.


## CIS Kubernetes Benchmark support

kube-bench runs industry standard benchmark tests for Kubernetes. Most of our supported benchmarks are defined in either of the following:

| Source | Kubernetes Benchmark | kube-bench config   | Kubernetes versions      |
|--------|---------------------|---------------------|-------------------------|
| CIS    | 1.9                 | cis-1.9             | 1.27.x                  |
| CIS    | 1.10                | cis-1.10            | ≥ 1.28                  |
| CIS    | 1.11                | cis-1.11            | ≥ 1.29                  |
| CIS    | rke2-1.9.0          | rke2-cis-1.9        | rke2 1.27.x             |
| CIS    | rke2-1.10.0         | rke2-cis-1.10       | ≥ rke2 1.28             |
| CIS    | k3s-1.9.0           | k3s-cis-1.9         | k3s 1.27.x              |
| CIS    | k3s-1.10.0          | k3s-cis-1.10        | ≥ k3s 1.28              |
| CIS    | GKE 1.6.0           | gke-1.6.0           | GKE                     |
| CIS    | AKS 1.0.0           | aks-1.0             | AKS                     |
| CIS    | EKS 1.5.0           | eks-1.5.0           | EKS                     |

