# vSphere Cloud Provider Interface (CPI)

[vSphere Cloud Provider Interface (CPI)](https://github.com/kubernetes/cloud-provider-vsphere) is responsible for running all the platform specific control loops that were previously run in core Kubernetes components like the KCM and the kubelet, but have been moved out-of-tree to allow cloud and infrastructure providers to implement integrations that can be developed, built and released independent of Kubernetes core. The official documentation and tutorials can be found [here](https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/prerequisites.html).

## Prerequisites

- vSphere 6.7 U3+
- Kubernetes v1.14+
- A Secret on your Kubernetes cluster that contains vSphere credentials (Refer to `README` or `Detailed Descriptions`)

## Installation

This chart requires a Secret in your Kubernetes cluster that contains the server URL and credentials to connect to the vCenter. You can have the chart generate it for you, or create it yourself and provide the name of the Secret during installation. 

<span style="color:orange">Warning</span>: When the option to generate the Secret is enabled, the credentials are visible in the API to authorized users. If you create the Secret yourself they will not be visible.

You can create a Secret in one of the following ways:
### <B>Option 1</b>: Create a Secret using the Rancher UI
Go to your cluster's project (Same project you will be installing the chart) > Resources > Secrets > Add Secret.
```yaml
# Example of data required in the Secret
<host-1>.username: <username>
<host-1>.password: <password>
```

### <B>Option 2</b>: Create a Secret using kubectl
Replace placeholders with actual values, and execute the following:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
    name: <secret-name>
    namespace: <charts-namespace>
data:
    <host-1>.username: <base64encoded-username>
    <host-1>.password: <base64encoded-password>
EOF
```

More information on managing Secrets using kubectl [here](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/).

## Migration

If using this chart to migrate volumes provisioned by the in-tree provider to the out-of-tree CPI + CSI, you need to taint all nodes with the following:
```
node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule
```

A script [taints.sh](../taints.sh) has been added for your convenience, and it can be executed with the following command:
```
# Optionally, a path to a kube config can be provided for cases
# where the script needs to be executed from outside of the cluster
./taints.sh <optional-path-to-kubeconfig>
```
