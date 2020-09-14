# Rancher CIS Benchmark Chart

The cis-operator enables running CIS benchmark security scans on a kubernetes cluster and generate compliance reports.

# Installation

### Requirements

This chart depends on the rancher-cis-benchmark-crd chart.

### Installation
```
helm install rancher-cis-benchmark ./ --create-namespace -n cis-operator-system
```
