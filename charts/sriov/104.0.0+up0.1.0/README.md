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

In the case that [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) is enabled, the sriov network operator namespace will require a security level of 'privileged'
```
$ kubectl label ns sriov-network-operator pod-security.kubernetes.io/enforce=privileged
```

## Chart parameters

In order to tailor the deployment of the network operator to your cluster needs
We have introduced the following Chart parameters.

| Name | Type | Default | description |
| ---- |------|---------|-------------|
| `imagePullSecrets` | list | `[]` | An optional list of references to secrets to use for pulling any of the SR-IOV Network Operator image |

### Operator parameters

| Name | Type | Default | description |
| ---- | ---- | ------- | ----------- |
| `operator.tolerations` | list | `[{"key":"node-role.kubernetes.io/master","operator":"Exists","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]` | Operator's tolerations |
| `operator.nodeSelector` | object | {} | Operator's node selector |
| `operator.affinity` | object | `{"nodeAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"weight":1,"preference":{"matchExpressions":[{"key":"node-role.kubernetes.io/master","operator":"In","values":[""]}]}},{"weight":1,"preference":{"matchExpressions":[{"key":"node-role.kubernetes.io/control-plane","operator":"In","values":[""]}]}}]}}` | Operator's afffinity configuration |
| `operator.nameOverride` | string | `` | Operator's resource name override |
| `operator.fullnameOverride` | string | `` | Operator's resource full name override |
| `operator.resourcePrefix` | string | `openshift.io` | Device plugin resource prefix |
| `operator.cniBinPath` | string | `/opt/cni/bin` | Path for CNI binary |
| `operator.clustertype` | string | `kubernetes` | Cluster environment type |

#### Admission Controllers parameters

The admission controllers can be enabled by switching on a single parameter `operator.admissionControllers.enabled`. By
default, the user needs to pre-create Kubernetes Secrets that match the names provided in
`operator.admissionControllers.certificates.secretNames`. The secrets should have 3 fields populated with the relevant
content:
* `ca.crt` (value needs to be base64 encoded twice)
* `tls.crt`
* `tls.key`

Aside from the aforementioned mode, the chart supports 3 more modes for certificate consumption by the admission
controllers, which can be found in the table below. In a nutshell, the modes that are supported are:
* Consume pre-created Certificates managed by cert-manager
* Generate self signed Certificates managed by cert-manager
* Specify the content of the certificates as Helm values

| Name | Type | Default | description |
| ---- | ---- | ------- | ----------- |
| `operator.admissionControllers.enabled` | bool | false | Flag that switches on the admission controllers |
| `operator.admissionControllers.certificates.secretNames.operator` | string | `operator-webhook-cert` | Secret that stores the certificate for the Operator's admission controller |
| `operator.admissionControllers.certificates.secretNames.injector` | string | `network-resources-injector-cert` | Secret that stores the certificate for the Network Resources Injector's admission controller  |
| `operator.admissionControllers.certificates.certManager.enabled` | bool | false | Flag that switches on consumption of certificates managed by cert-manager |
| `operator.admissionControllers.certificates.certManager.generateSelfSigned` | bool | false | Flag that switches on generation of self signed certificates managed by cert-manager. The secrets in which the certificates are stored will have the names provided in `operator.admissionControllers.certificates.secretNames` |
| `operator.admissionControllers.certificates.custom.enabled` | bool | false | Flag that switches on consumption of user provided certificates that are part of `operator.admissionControllers.certificates.custom.operator` and `operator.admissionControllers.certificates.custom.injector` objects |
| `operator.admissionControllers.certificates.custom.operator.caCrt` | string | `` | The CA certificate to be used by the Operator's admission controller |
| `operator.admissionControllers.certificates.custom.operator.tlsCrt` | string | `` | The public part of the certificate to be used by the Operator's admission controller |
| `operator.admissionControllers.certificates.custom.operator.tlsKey` | string | `` | The private part of the certificate to be used by the Operator's admission controller |
| `operator.admissionControllers.certificates.custom.injector.caCrt` | string | `` | The CA certificate to be used by the Network Resources Injector's admission controller |
| `operator.admissionControllers.certificates.custom.injector.tlsCrt` | string | `` | The public part of the certificate to be used by the Network Resources Injector's admission controller |
| `operator.admissionControllers.certificates.custom.injector.tlsKey` | string | `` | The private part of the certificate to be used by the Network Resources Injector's admission controller |

### SR-IOV Operator Configuration Parameters

This section contains general parameters that apply to both the operator and daemon componets of SR-IOV Network Operator.

| Name | Type | Default | description |
| ---- | ---- | ------- | ----------- |
| `sriovOperatorConfig.deploy` | bool | `false` | deploy SriovOperatorConfig custom resource |
| `sriovOperatorConfig.configDaemonNodeSelector` | map[string]string | `{}` | node slectors for sriov-network-config-daemon |
| `sriovOperatorConfig.logLevel` | int | `2` | log level for both operator and sriov-network-config-daemon |
| `sriovOperatorConfig.disableDrain` | bool | `false` | disable node draining when configuring SR-IOV, set to true in case of a single node cluster or any other justifiable reason |
| `sriovOperatorConfig.configurationMode` | string | `daemon` | sriov-network-config-daemon configuration mode. either `daemon` or `systemd` |

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
