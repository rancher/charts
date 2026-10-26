# Rancher CIS Benchmark Chart

The cis-operator enables running CIS benchmark security scans on a kubernetes cluster and generate compliance reports that can be downloaded.

# Installation

```
helm install rancher-cis-benchmark ./ --create-namespace -n cis-operator-system
```
