# SR-IOV Network Operator Helm Chart

SR-IOV Network Operator Helm Chart provides an easy way to install, configure and manage
the lifecycle of SR-IOV network operator.

## SR-IOV Network Operator
SR-IOV Network Operator leverages [Kubernetes CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
and [Operator SDK](https://github.com/operator-framework/operator-sdk) to configure and manage SR-IOV networks in a Kubernetes cluster.

SR-IOV Network Operator features:
- Initialize the supported SR-IOV NIC types on selected nodes.
- Provision/upgrade SR-IOV device plugin executable on selected node.
- Provision/upgrade SR-IOV CNI plugin executable on selected nodes.
- Manage configuration of SR-IOV device plugin on host.
- Generate net-att-def CRs for SR-IOV CNI plugin
- Supports operation in a virtualized Kubernetes deployment
  - Discovers VFs attached to the Virtual Machine (VM)
  - Does not require attached of associated PFs
  - VFs can be associated to SriovNetworks by selecting the appropriate PciAddress as the RootDevice in the SriovNetworkNodePolicy

## QuickStart

### Prerequisites

- Kubernetes v1.17+
- Helm v3

### Install Helm

Helm provides an install script to copy helm binary to your system:
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 500 get_helm.sh
$ ./get_helm.sh
```

For additional information and methods for installing Helm, refer to the official [helm website](https://helm.sh/)

### Deploy SR-IOV Network Operator

```
# Install Operator
$ helm install -n sriov-network-operator --create-namespace --wait sriov-network-operator ./

# View deployed resources
$ kubectl -n sriov-network-operator get pods
```

## Chart parameters

In order to tailor the deployment of the network operator to your cluster needs
We have introduced the following Chart parameters.

### Operator parameters

| Name | Type | Default | description |
| ---- | ---- | ------- | ----------- |
| `operator.resourcePrefix` | string | `openshift.io` | Device plugin resource prefix |
| `operator.enableAdmissionController` | bool | `false` | Enable SR-IOV network resource injector and operator webhook |
| `operator.cniBinPath` | string | `/opt/cni/bin` | Path for CNI binary |
| `operator.clusterType` | string | `kubernetes` | Cluster environment type |

### Images parameters

| Name | description |
| ---- | ----------- |
| `images.operator` | Operator controller image |
| `images.sriovConfigDaemon` | Daemon node agent image |
| `images.sriovCni` | SR-IOV CNI image |
| `images.ibSriovCni` | InfiniBand SR-IOV CNI image |
| `images.sriovDevicePlugin` | SR-IOV device plugin image |
| `images.resourcesInjector` | Resources Injector image |
| `images.webhook` | Operator Webhook image |
