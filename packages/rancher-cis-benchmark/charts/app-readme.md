# Rancher CIS Benchmark

This chart installs the following components to enable security scanning of your cluster using benchmarks published by CIS (Center for Internet Security):

## Workloads
* [cis-operator](https://github.com/rancher/cis-operator)- The cis-operator handles launching the [kube-bench](https://github.com/aquasecurity/kube-bench) tool that runs a suite of CIS tests on the nodes of your Kubernetes cluster. After scans finish, the cis-operator generates a compliance report that can be downloaded.

## CRDs & CRs
* `ClusterScanBenchmark` - A `ClusterScanBenchmark` is a CRD that is used to define the CIS benchmark version to run using kube-bench as well as the valid configuration parameters for that benchmark. This chart installs a few default `ClusterScanBenchmark` custom resources.
* `ClusterScanProfile` - A `ClusterScanProfile` is a CRD that is used to define the configuration for the CIS scan, which is the benchmark versions to use and any specific tests to skip in that benchmark. This chart installs a few default `ClusterScanProfile` custom resources with no skipped tests, which can immediately be used to launch CIS scans. 
* `ClusterScan` - A `ClusterScan` is a CRD that is used to define when to trigger CIS scans on the cluster based on the defined profile. A report is created after the scan is completed.
* `ClusterScanReport` - A `ClusterScanReport` is a CRD that is used to display results of a CIS scan of the cluster.
