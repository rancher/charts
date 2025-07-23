
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
