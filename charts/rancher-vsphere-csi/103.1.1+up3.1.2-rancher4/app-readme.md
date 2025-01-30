# vSphere Container Storage Interface (CSI)

[vSphere Container Storage Interface (CSI)](https://github.com/kubernetes-sigs/vsphere-csi-driver) is a specification designed to enable persistent storage volume management on Container Orchestrators (COs) such as Kubernetes. The specification allows storage systems to integrate with containerized workloads running on Kubernetes. Using CSI, storage providers, such as VMware, can write and deploy plugins for storage systems in Kubernetes without a need to modify any core Kubernetes code.

CSI allows volume plugins to be installed on Kubernetes clusters as extensions. Once a CSI compatible volume driver is deployed on a Kubernetes cluster, users can use the CSI to provision, attach, mount, and format the volumes exposed by the CSI driver.

The CSI driver for vSphere is `csi.vsphere.vmware.com`.

## Prerequisites

- vSphere 6.7 U3+
- Kubernetes v1.14+
- Out-of-tree vSphere Cloud Provider Interface (CPI)
- A Secret on your Kubernetes cluster that contains vSphere CSI configuration and credentials (Refer to `README` or `Detailed Descriptions`)
