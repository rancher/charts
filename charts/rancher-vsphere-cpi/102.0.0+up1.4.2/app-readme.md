# vSphere Cloud Provider Interface (CPI)

[vSphere Cloud Provider Interface (CPI)](https://github.com/kubernetes/cloud-provider-vsphere) is responsible for running all the platform specific control loops that were previously run in core Kubernetes components like the KCM and the kubelet, but have been moved out-of-tree to allow cloud and infrastructure providers to implement integrations that can be developed, built and released independent of Kubernetes core. The official documentation and tutorials can be found [here](https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/prerequisites.html).

**This chart requires being deployed into the `kube-system` namespace.**

## Prerequisites

- vSphere 6.7 U3+ or vSphere 7.0+
- Kubernetes v1.19+
- A Secret on your Kubernetes cluster that contains vSphere credentials (Refer to `README` or `Detailed Descriptions`)
