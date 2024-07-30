# vSphere Container Storage Interface (CSI)

[vSphere Container Storage Interface (CSI)](https://github.com/kubernetes-sigs/vsphere-csi-driver/tree/release-2.1/manifests/v2.1.0/vsphere-7.0u1/) is a specification designed to enable persistent storage volume management on Container Orchestrators (COs) such as Kubernetes. The specification allows storage systems to integrate with containerized workloads running on Kubernetes. Using CSI, storage providers, such as VMware, can write and deploy plugins for storage systems in Kubernetes without a need to modify any core Kubernetes code.

CSI allows volume plugins to be installed on Kubernetes clusters as extensions. Once a CSI compatible volume driver is deployed on a Kubernetes cluster, users can use the CSI to provision, attach, mount, and format the volumes exposed by the CSI driver.

The CSI driver for vSphere is `csi.vsphere.vmware.com`.

## Prerequisites

- vSphere 6.7 U3+
- Kubernetes v1.20+
- Out-of-tree vSphere Cloud Provider Interface (CPI)
- A Secret on your Kubernetes cluster that contains vSphere CSI configuration and credentials

## Installation

This chart requires a Secret in your Kubernetes cluster that contains the CSI configuration and credentials to connect to the vCenter. You can have the chart generate it for you, or create it yourself and provide the name of the Secret during installation.

<span style="color:orange">Warning</span>: When the option to generate the Secret is enabled, the credentials are visible in the API to authorized users. If you create the Secret yourself they will not be visible.

You can create a Secret in one of the following ways:

### <B>Option 1</b>: Create a Secret using the Rancher UI

Go to your cluster's project (Same project you will be installing the chart) > Resources > Secrets > Add Secret.
```yaml
# Example of data required in the Secret
# The csi-vsphere.conf key name is required, otherwise the installation will fail
csi-vsphere.conf: |
  [Global]
  cluster-id = "<cluster-id>"
  user = "<username>"
  password = "<password>"
  port = "<port>"
  insecure-flag = "<insecure-flag>"

  [VirtualCenter "<host>"]
  datacenters = "<dc-1>, <dc-2>, ..."
```
More information on CSI vSphere configuration [here](https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/installation.html#create_k8s_secret).

### <B>Option 2</b>: Create a Secret using kubectl

Replace placeholders with actual values, and execute the following:
```bash
# The csi-vsphere.conf key name is required, otherwise the installation will fail
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: <secret-name>
  namespace: <charts-namespace>
stringData:
  csi-vsphere.conf: |
    [Global]
    cluster-id = "<cluster-id>"
    user = "<username>"
    password = "<password>"
    port = "<port>"
    insecure-flag = "<insecure-flag>"

    [VirtualCenter "<host>"]
    datacenters = "<dc-1>, <dc-2>, ..."
EOF
```

More information on managing Secrets using kubectl [here](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/).

## Migration

The CSI migration feature is only available for vSphere 7.0 U1.

## vSphere CSI with Topology

When deploying to a vSphere environment using zoning, the topology plugin can be enabled for the CSI to make intelligent volume provisioning decisions. More information on vSphere zoning and prerequisites for the CSI toplogy plugin can be found [here](https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-162E7582-723B-4A0F-A937-3ACE82EAFD31.html#guidelines-and-best-practices-for-deployment-with-topology-0).

To enable the topology plugin, adjust the values for the chart as follows:

```yaml
topology:
  enabled: true
```