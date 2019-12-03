# StorageOS Operator Helm Chart

> **Note**: This is the recommended chart to use for installing StorageOS. It
installs the StorageOS Operator, and then installs a StorageOS cluster with a
minimal configuration. Other Helm charts
([storageoscluster-operator](https://github.com/storageos/charts/tree/master/stable/storageoscluster-operator)
and
[storageos](https://github.com/storageos/charts/tree/master/stable/storageos))
will be deprecated.

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
- Kubernetes 1.9 only:
  - Feature gate: MountPropagation=true.  This can be done by appending
    `--feature-gates MountPropagation=true` to the kube-apiserver and kubelet
    services.

Refer to the [StorageOS prerequisites
docs](https://docs.storageos.com/docs/prerequisites/overview) for more
information.

## Installing the chart

```console
# Add storageos charts repo.
$ helm repo add storageos https://charts.storageos.com
# Install the chart in a namespace.
$ helm install storageos/storageos-operator --namespace storageos-operator
```

This will install the StorageOSCluster operator in `storageos-operator`
namespace and deploys StorageOS with a minimal configuration.

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
  namespace: "default"
  labels:
    app: "storageos"
type: "kubernetes.io/storageos"
data:
  # echo -n '<secret>' | base64
  apiAddress: c3RvcmFnZW9zOjU3MDU=
  apiUsername: c3RvcmFnZW9z
  apiPassword: c3RvcmFnZW9z
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
  secretRefNamespace: "default"
```

Once the `StorageOSCluster` configuration is applied, the StorageOSCluster
operator will create a StorageOS cluster in the `storageos` namespace by
default.

Most installations will want to use the default [CSI](https://kubernetes-csi.github.io/docs/)
driver.  To use the [Native Driver](https://kubernetes.io/docs/concepts/storage/volumes/#storageos)
instead, disable CSI:

```yaml
spec:
  ...
  csi:
    enable: false
  ...
```

in the above `StorageOSCluster` resource config.

Learn more about advanced configuration options
[here](https://github.com/storageos/cluster-operator/blob/master/README.md#storageoscluster-resource-configuration).

To check cluster status, run:

```bash
$ kubectl get storageoscluster
NAME                READY     STATUS    AGE
example-storageos   3/3       Running   4m
```

All the events related to this cluster are logged as part of the cluster object
and can be viewed by describing the object.

```bash
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
`operator.image.tag` | StorageOS Operator container image tag | `1.5.1`
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
`cluster.kvBackend.embedded` | Use StorageOS embedded etcd | `true`
`cluster.kvBackend.address` | List of etcd targets, in the form ip[:port], separated by commas |
`cluster.kvBackend.backend` | Key-Value store backend name | `etcd`
`cluster.kvBackend.tlsSecretName` | Name of the secret containing kv backend tls cert |
`cluster.kvBackend.tlsSecretNamespace` | Namespace of the secret containing kv backend tls cert |
`cluster.nodeSelectorTerm.key` | Key of the node selector term used for pod placement |
`cluster.nodeSelectorTerm.value` | Value of the node selector term used for pod placement |
`cluster.toleration.key` | Key of the pod toleration parameter |
`cluster.toleration.value` | Value of the pod toleration parameter |
`cluster.disableTelemetry` | If true, no telemetry data will be collected from the cluster | `false`
`cluster.images.node.repository` | StorageOS Node container image repository | `storageos/node`
`cluster.images.node.tag` | StorageOS Node container image tag | `1.5.1`
`cluster.csi.enable` | If true, CSI driver is enabled | `true`
`cluster.csi.deploymentStrategy` | Whether CSI helpers should be deployed as a `deployment` or `statefulset` | `deployment`

## Deleting a StorageOS Cluster

Deleting the `StorageOSCluster` custom resource object would delete the
storageos cluster and all the associated resources.

In the above example,

```bash
kubectl delete storageoscluster example-storageos
```

would delete the custom resource and the cluster.

## Uninstalling the Chart

To uninstall/delete the storageos cluster operator deployment:

```bash
helm delete --purge <release-name>
```

Learn more about configuring the StorageOS Operator on
[GitHub](https://github.com/storageos/cluster-operator).
