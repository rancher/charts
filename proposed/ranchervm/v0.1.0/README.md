## Prerequisites

1. Kubernetes v1.10+
2. `qemu-kvm` installed on all Kubernetes nodes

## Uninstall

1. Delete all Instances in RancherVM and wait until they are cleaned up.
2. Delete the `ranchervm` deployment from `Catalog Apps` screen.

## Source Code

RancherVM is 100% open source software. Project source code is available in these repositories:

1. [K8s Controllers and REST API](https://github.com/rancher/vm)
2. [Dashboard](https://github.com/llparse/longhorn-ui/tree/ranchervm)
3. [Rancher 2.0 Chart](https://github.com/llparse/charts-rancher/tree/ranchervm-charts/proposed/ranchervm/latest)

---
Please see [link](https://github.com/rancher/vm) for more information.
