# etcd-operator

[etcd-operator](https://coreos.com/blog/introducing-the-etcd-operator.html) Simplify etcd cluster configuration and management.

__DISCLAIMER:__ While this chart has been well-tested, the etcd-operator is still currently in beta. Current project status is available [here](https://github.com/coreos/etcd-operator).

## Introduction

This chart bootstraps an etcd-operator and allows the deployment of etcd-cluster(s).

### How to use it
With etcd-operator, users can now create a custom etcd cluster using custom resource definitions(CRDs) like EtcdCluster, EtcdBackup and EtcdRestore . e.g,
```YAML
apiVersion: etcd.database.coreos.com/v1beta2
kind: EtcdCluster
metadata:
  name: "example-etcd-cluster"
  ## Adding this annotation make this cluster managed by clusterwide operators, namespaced operators ignore it
  # annotations:
    # etcd.database.coreos.com/scope: clusterwide
spec:
  size: 3
  version: "3.2.25"
```

For more details about CRD spec please refer to the [etcd-operator doc](https://github.com/coreos/etcd-operator/blob/master/doc/user/spec_examples.md).
