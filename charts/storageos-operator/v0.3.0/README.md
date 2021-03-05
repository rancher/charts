# StorageOS Operator Helm Chart

> **Note**: This chart defaults to StorageOS v2. To upgrade from a previous
> chart or from StorageOS version 1.x to 2.x, please contact support for
> assistance.

[StorageOS](https://storageos.com) is a software-based storage platform
designed for cloud-native applications. By deploying StorageOS on your
Kubernetes cluster, local storage from cluster node is aggregated into a
distributed pool, and persistent volumes created from it using the native
Kubernetes volume driver are available instantly to pods wherever they move in
the cluster.

Features such as replication, encryption and caching help protect data and
maximise performance.

This chart installs a StorageOS Cluster Operator which helps deploy and
configure a StorageOS cluster on kubernetes.

## Prerequisites

- Helm 2.10+
- Kubernetes 1.9+.
- Privileged mode containers (enabled by default)
- Etcd cluster
- Kubernetes 1.9 only:
  - Feature gate: MountPropagation=true.  This can be done by appending
    `--feature-gates MountPropagation=true` to the kube-apiserver and kubelet
    services.

Refer to the [StorageOS prerequisites
docs](https://docs.storageos.com/docs/prerequisites/) for more information.

## Installing the chart

```console
# Add storageos charts repo.
$ helm repo add storageos https://charts.storageos.com
# Install the chart in a namespace.
$ helm install storageos/storageos-operator \
    --namespace storageos-operator \
    --set cluster.kvBackend.address=<etcd-node-ip>:2379 \
    --set cluster.admin.password=<password>
```

This will install the StorageOSCluster operator in `storageos-operator`
namespace and deploys StorageOS with a minimal configuration. Etcd address
(kvBackend) and admin password are mandatory values to install the chart. To
avoid passing the password as a flag, create a values.yaml file and pass the
file name with `--values` flag.

```yaml
cluster:
  kvBackend:
    address: <etcd-node-ip>:2379
  admin:
    password: <password>
```

The password must be at least 8 characters long and the default username is
`storageos`, which can be changed like the above values. Find more information
about installing etcd in our [etcd
docs](https://docs.storageos.com/docs/prerequisites/etcd/).

Install the chart with the values file:

```console
$ helm install storageos/storageos-operator \
    --namespace storageos-operator \
    --values <values-file>
```

> **Tip**: List all releases using `helm list`

## Creating a StorageOS cluster manually

The Helm chart supports a subset of StorageOSCluster custom resource parameters.
For advanced configurations, you may wish to create the cluster resource
manually and only use the Helm chart to install the Operator.

To disable auto-provisioning the cluster with the Helm chart, set
`cluster.create` to false:

```yaml
cluster:
  ...
  create: false
```

Create a secret to store storageos cluster secrets:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: "storageos-api"
  namespace: "storageos-operator"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  # echo -n '<secret>' | base64
  apiUsername: c3RvcmFnZW9z
  apiPassword: c3RvcmFnZW9z
  csiProvisionUsername: c3RvcmFnZW9z
  csiProvisionPassword: c3RvcmFnZW9z
  csiControllerPublishUsername: c3RvcmFnZW9z
  csiControllerPublishPassword: c3RvcmFnZW9z
  csiNodePublishUsername: c3RvcmFnZW9z
  csiNodePublishPassword: c3RvcmFnZW9z
  csiControllerExpandUsername: c3RvcmFnZW9z
  csiControllerExpandPassword: c3RvcmFnZW9z
```

Create a `StorageOSCluster` custom resource and refer the above secret in
`secretRefName` and `secretRefNamespace` fields.

```yaml
apiVersion: "storageos.com/v1"
kind: "StorageOSCluster"
metadata:
  name: "example-storageos"
  namespace: "default"
spec:
  secretRefName: "storageos-api"
  secretRefNamespace: "storageos-operator"
  csi:
    enable: true
    deploymentStrategy: "deployment"
    enableProvisionCreds: true
    enableControllerPublishCreds: true
    enableNodePublishCreds: true
    enableControllerExpandCreds: true
  kvBackend:
    address: "etcd-client.etcd.svc.cluster.local:2379"
    # address: '10.42.15.23:2379,10.42.12.22:2379,10.42.13.16:2379' # You can set ETCD server IPs.
```

Once the `StorageOSCluster` configuration is applied, the StorageOSCluster
operator will create a StorageOS cluster in the `kube-system` namespace by
default. Installing into the kube-system namespace is recommended so that the
storage containers can be marked as system-node-critical. This reduces the risk
that the storage containers get evicted before applications that require the
storage they provide.

Learn more about advanced configuration options
[here](https://github.com/storageos/cluster-operator/blob/master/README.md#storageoscluster-resource-configuration).

To check cluster status, run:

```console
$ kubectl get storageoscluster
NAME                READY     STATUS    AGE
example-storageos   3/3       Running   4m
```

All the events related to this cluster are logged as part of the cluster object
and can be viewed by describing the object.

```console
$ kubectl describe storageoscluster example-storageos
Name:         example-storageos
Namespace:    default
Labels:       <none>
...
...
Events:
  Type     Reason         Age              From                       Message
  ----     ------         ----             ----                       -------
  Warning  ChangedStatus  1m (x2 over 1m)  storageos-operator  0/3 StorageOS nodes are functional
  Normal   ChangedStatus  35s              storageos-operator  3/3 StorageOS nodes are functional. Cluster healthy
```

## Configuration

The following tables lists the configurable parameters of the StorageOSCluster
Operator chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`operator.image.repository` | StorageOS Operator container image repository | `storageos/cluster-operator`
`operator.image.tag` | StorageOS Operator container image tag | `v2.1.0`
`operator.image.pullPolicy` | StorageOS Operator container image pull policy | `IfNotPresent`
`podSecurityPolicy.enabled` | If true, create & use PodSecurityPolicy resources | `false`
`podSecurityPolicy.annotations` | Specify pod annotations in the pod security policy | `{}`
`cluster.create` | If true, auto-create the StorageOS cluster | `true`
`cluster.name` | Name of the storageos deployment | `storageos`
`cluster.namespace` | Namespace to install the StorageOS cluster into | `kube-system`
`cluster.secretRefName` | Name of the secret containing StorageOS API credentials | `storageos-api`
`cluster.admin.username` | Username to authenticate to the StorageOS API with | `storageos`
`cluster.admin.password` | Password to authenticate to the StorageOS API with |
`cluster.sharedDir` | The path shared into to kubelet container when running kubelet in a container |
`cluster.kvBackend.address` | List of etcd targets, in the form ip[:port], separated by commas |
`cluster.kvBackend.backend` | Key-Value store backend name | `etcd`
`cluster.kvBackend.tlsSecretName` | Name of the secret containing kv backend tls cert |
`cluster.kvBackend.tlsSecretNamespace` | Namespace of the secret containing kv backend tls cert |
`cluster.nodeSelectorTerm.key` | Key of the node selector term used for pod placement |
`cluster.nodeSelectorTerm.value` | Value of the node selector term used for pod placement |
`cluster.toleration.key` | Key of the pod toleration parameter |
`cluster.toleration.value` | Value of the pod toleration parameter |
`cluster.disableTelemetry` | If true, no telemetry data will be collected from the cluster | `false`
`cluster.images.node.repository` | StorageOS Node container image repository |
`cluster.images.node.tag` | StorageOS Node container image tag |
`cluster.images.init.repository` | StorageOS init container image repository |
`cluster.images.init.tag` | StorageOS init container image tag |
`cluster.images.csiV1ClusterDriverRegistrar.repository` | CSI v1 Cluster Driver Registrar image repository |
`cluster.images.csiV1ClusterDriverRegistrar.tag` | CSI v1 Cluster Driver Registrar image tag |
`cluster.images.csiV1NodeDriverRegistrar.repository` | CSI v1 Node Driver Registrar image repository |
`cluster.images.csiV1NodeDriverRegistrar.tag` | CSI v1 Node Driver Registrar image tag |
`cluster.images.csiV1ExternalProvisioner.repository` | CSI v1 External Provisioner image repository |
`cluster.images.csiV1ExternalProvisioner.tag` | CSI v1 External Provisioner image tag |
`cluster.images.csiV1ExternalAttacher.repository` | CSI v1 External Attacher image repository |
`cluster.images.csiV1ExternalAttacher.tag` | CSI v1 External Attacher image tag |
`cluster.images.csiV1ExternalAttacherV2.repository` | CSI v1 External Attacher v2 image repository |
`cluster.images.csiV1ExternalAttacherV2.tag` | CSI v1 External Attacher v2 image tag |
`cluster.images.csiV1LivenessProbe.repository` | CSI v1 Liveness Probe image repository |
`cluster.images.csiV1LivenessProbe.tag` | CSI v1 Liveness Probe image tag |
`cluster.images.csiV1ExternalResizer.repository` | CSI v1 External Resizer image repository |
`cluster.images.csiV1ExternalResizer.tag` | CSI v1 External Resizer image tag |
`cluster.images.kubeScheduler.repository` | Kube Scheduler container image repository |
`cluster.images.kubeScheduler.tag` | Kube Scheduler container image tag |

## Deleting a StorageOS Cluster

Deleting the `StorageOSCluster` custom resource object would delete the
storageos cluster and all the associated resources.

In the above example,

```console
kubectl delete storageoscluster example-storageos
```

would delete the custom resource and the cluster.

## Uninstalling the Chart

To uninstall/delete the storageos cluster operator deployment:

```console
helm delete --purge <release-name>
```

Learn more about configuring the StorageOS Operator on
[GitHub](https://github.com/storageos/cluster-operator).
