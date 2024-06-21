# Rancher CIS Benchmarks

This chart enables security scanning of the cluster using [CIS (Center for Internet Security) benchmarks](https://www.cisecurity.org/benchmark/kubernetes/).

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/cis-scans/v2.5/).

This chart installs the following components:

- [cis-operator](https://github.com/rancher/cis-operator) - The cis-operator handles launching the [kube-bench](https://github.com/aquasecurity/kube-bench) tool that runs a suite of CIS tests on the nodes of your Kubernetes cluster. After scans finish, the cis-operator generates a compliance report that can be downloaded.
- Scans - A scan is a CRD (`ClusterScan`) that defines when to trigger CIS scans on the cluster based on the defined profile. A report is created after the scan is completed.
- Profiles - A profile is a CRD (`ClusterScanProfile`) that defines the configuration for the CIS scan, which is the benchmark versions to use and any specific tests to skip in that benchmark. This chart installs a few default `ClusterScanProfile` custom resources with no skipped tests, which can immediately be used to launch CIS scans.
- Benchmark Versions - A benchmark version is a CRD (`ClusterScanBenchmark`) that defines the CIS benchmark version to run using kube-bench as well as the valid configuration parameters for that benchmark. This chart installs a few default `ClusterScanBenchmark` custom resources.
- Alerting Resources - Rancher's CIS Benchmark application lets you run a cluster scan on a schedule, and send alerts when scans finish.
    - If you want to enable alerts to be delivered when a cluster scan completes, you need to ensure that [Rancher's Monitoring and Alerting](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/) application is pre-installed and the [Receivers and Routes](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/configuration/#alertmanager-config) are configured to send out alerts.
    - Additionally, you need to set `alerts: true` in the Values YAML while installing or upgrading this chart.
