# OpenEBS Helm Chart

[OpenEBS](https://github.com/openebs/openebs) is an *open source storage platform* that provides persistent and containerized block storage for DevOps and container environments. 
OpenEBS provides multiple storage engines that can be plugged in easily. A common pattern is the use of OpenEBS to deliver Dynamic LocalPV for those applications and workloads that want to access disks and cloud volumes directly.

OpenEBS can be deployed on any Kubernetes cluster - either in cloud, on-premise or developer laptop (minikube). OpenEBS itself is deployed as just another container on your cluster, and enables storage services that can be designated on a per pod, application, cluster or container level.

## Introduction

This chart bootstraps OpenEBS deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Quickstart and documentation

You can run OpenEBS on any Kubernetes 1.13+ cluster in a matter of seconds. See the [Quickstart Guide to OpenEBS](https://docs.openebs.io/docs/next/quickstart.html) for detailed instructions.

For more comprehensive documentation, start with the [Welcome to OpenEBS](https://docs.openebs.io/docs/next/overview.html) docs.

## Prerequisites

- Kubernetes 1.13+ with RBAC enabled
- iSCSI PV support in the underlying infrastructure

## Adding OpenEBS Helm repository

Before installing OpenEBS Helm charts, you need to add the [OpenEBS Helm repository](https://openebs.github.io/charts) to your Helm client.

```bash
helm repo add openebs https://openebs.github.io/charts
```

## Update the dependent charts

```bash
helm dependency update
```

## Installing OpenEBS

```bash
helm install --namespace openebs openebs/openebs
```

## Installing OpenEBS with the release name

```bash
helm install --name `my-release` --namespace openebs openebs/openebs
```

## To uninstall/delete instance with release name

```bash
helm ls --all
helm delete `my-release`
```

## Configuration

The following table lists the configurable parameters of the OpenEBS chart and their default values.

| Parameter                               | Description                                   | Default                                   |
| ----------------------------------------| --------------------------------------------- | ----------------------------------------- |
| `rbac.create`                           | Enable RBAC Resources                         | `true`                                    |
| `rbac.pspEnabled`                       | Create pod security policy resources          | `false`                                   |
| `image.pullPolicy`                      | Container pull policy                         | `IfNotPresent`                            |
| `image.repository`                      | Specify which docker registry to use          | `""`                                      |
| `apiserver.enabled`                     | Enable API Server                             | `true`                                    |
| `apiserver.image`                       | Image for API Server                          | `openebs/m-apiserver`                     |
| `apiserver.imageTag`                    | Image Tag for API Server                      | `2.10.0`                                  |
| `apiserver.replicas`                    | Number of API Server Replicas                 | `1`                                       |
| `apiserver.sparse.enabled`              | Create Sparse Pool based on Sparsefile        | `false`                                   |
| `apiserver.resources`                   | Set resource limits for API Server            | `{}`                                      |
| `provisioner.enabled`                   | Enable Provisioner                            | `true`                                    |
| `provisioner.image`                     | Image for Provisioner                         | `openebs/openebs-k8s-provisioner`         |
| `provisioner.imageTag`                  | Image Tag for Provisioner                     | `2.10.0`                                  |
| `provisioner.replicas`                  | Number of Provisioner Replicas                | `1`                                       |
| `provisioner.resources`                 | Set resource limits for Provisioner           | `{}`                                      |
| `provisioner.patchJivaNodeAffinity`     | Enable/disable node affinity on jiva replica deployment| `enabled`                                 |
| `localprovisioner.enabled`              | Enable localProvisioner                       | `true`                                    |
| `localprovisioner.image`                | Image for localProvisioner                    | `openebs/provisioner-localpv`             |
| `localprovisioner.imageTag`             | Image Tag for localProvisioner                | `2.10.0`                                  |
| `localprovisioner.replicas`             | Number of localProvisioner Replicas           | `1`                                       |
| `localprovisioner.basePath`             | BasePath for hostPath volumes on Nodes        | `/var/openebs/local`                      |
| `localprovisioner.resources`            | Set resource limits for localProvisioner      | `{}`                                      |
| `webhook.enabled`                       | Enable admission server                       | `true`                                    |
| `webhook.image`                         | Image for admission server                    | `openebs/admission-server`                |
| `webhook.imageTag`                      | Image Tag for admission server                | `2.10.0`                                  |
| `webhook.replicas`                      | Number of admission server Replicas           | `1`                                       |
| `webhook.hostNetwork`                   | Use hostNetwork in admission server           | `false`                                   |
| `webhook.resources`                     | Set resource limits for admission server      | `{}`                                      |
| `snapshotOperator.enabled`              | Enable Snapshot Provisioner                   | `true`                                    |
| `snapshotOperator.provisioner.image`    | Image for Snapshot Provisioner                | `openebs/snapshot-provisioner`            |
| `snapshotOperator.provisioner.imageTag` | Image Tag for Snapshot Provisioner            | `2.10.0`                                  |
| `snapshotOperator.controller.image`     | Image for Snapshot Controller                 | `openebs/snapshot-controller`             |
| `snapshotOperator.controller.imageTag`  | Image Tag for Snapshot Controller             | `2.10.0`                                  |
| `snapshotOperator.replicas`             | Number of Snapshot Operator Replicas          | `1`                                       |
| `snapshotOperator.provisioner.resources`| Set resource limits for Snapshot Provisioner  | `{}`                                      |
| `snapshotOperator.controller.resources` | Set resource limits for Snapshot Controller   | `{}`                                      |
| `ndm.enabled`                           | Enable Node Disk Manager                      | `true`                                    |
| `ndm.image`                             | Image for Node Disk Manager                   | `openebs/node-disk-manager`         |
| `ndm.imageTag`                          | Image Tag for Node Disk Manager               | `1.5.0`                                   |
| `ndm.sparse.path`                       | Directory where Sparse files are created      | `/var/openebs/sparse`                     |
| `ndm.sparse.size`                       | Size of the sparse file in bytes              | `10737418240`                             |
| `ndm.sparse.count`                      | Number of sparse files to be created          | `0`                                       |
| `ndm.filters.enableOsDiskExcludeFilter` | Enable filters of OS disk exclude             | `true`                                    |
| `ndm.filters.osDiskExcludePaths`        | Paths/Mountpoints to be excluded by OS Disk Filter| `/,/etc/hosts,/boot`                           |
| `ndm.filters.enableVendorFilter`        | Enable filters of vendors                     | `true`                                    |
| `ndm.filters.excludeVendors`            | Exclude devices with specified vendor         | `CLOUDBYT,OpenEBS`                        |
| `ndm.filters.enablePathFilter`          | Enable filters of paths                       | `true`                                    |
| `ndm.filters.includePaths`              | Include devices with specified path patterns  | `""`                                      |
| `ndm.filters.excludePaths`              | Exclude devices with specified path patterns  | `/dev/loop,/dev/fd0,/dev/sr0,/dev/ram,/dev/dm-,/dev/md,/dev/rbd,/dev/zd`|
| `ndm.probes.enableSeachest`             | Enable Seachest probe for NDM                 | `false`                                   |
| `ndm.resources`                         | Set resource limits for NDM                   | `{}`                                      |
| `ndmOperator.enabled`                   | Enable NDM Operator                           | `true`                                    |
| `ndmOperator.image`                     | Image for NDM Operator                        | `openebs/node-disk-operator`        |
| `ndmOperator.imageTag`                  | Image Tag for NDM Operator                    | `1.5.0`                                   |
| `ndmOperator.resources`                 | Set resource limits for NDM Operator          | `{}`                                      |
| `jiva.image`                            | Image for Jiva                                | `openebs/jiva`                            |
| `jiva.imageTag`                         | Image Tag for Jiva                            | `2.10.0`                                  |
| `jiva.replicas`                         | Number of Jiva Replicas                       | `3`                                       |
| `jiva.defaultStoragePath`               | hostpath used by default Jiva StorageClass    | `/var/openebs`                            |
| `cstor.pool.image`                      | Image for cStor Pool                          | `openebs/cstor-pool`                      |
| `cstor.pool.imageTag`                   | Image Tag for cStor Pool                      | `2.10.0`                                  |
| `cstor.poolMgmt.image`                  | Image for cStor Pool  Management              | `openebs/cstor-pool-mgmt`                 |
| `cstor.poolMgmt.imageTag`               | Image Tag for cStor Pool Management           | `2.10.0`                                  |
| `cstor.target.image`                    | Image for cStor Target                        | `openebs/cstor-istgt`                     |
| `cstor.target.imageTag`                 | Image Tag for cStor Target                    | `2.10.0`                                  |
| `cstor.volumeMgmt.image`                | Image for cStor Volume  Management            | `openebs/cstor-volume-mgmt`               |
| `cstor.volumeMgmt.imageTag`             | Image Tag for cStor Volume Management         | `2.10.0`                                  |
| `helper.image`                          | Image for helper                              | `openebs/linux-utils`                     |
| `helper.imageTag`                       | Image Tag for helper                          | `2.10.0`                                  |
| `featureGates.enabled`                  | Enable feature gates for OpenEBS              | `true`                                   |
| `featureGates.GPTBasedUUID.enabled`     | Enable GPT based UUID generation in NDM       | `true`                                   |
| `featureGates.APIService.enabled`       | Enable APIService in NDM                      | `false`                                  |
| `featureGates.UseOSDisk.enabled`        | Enable using unused partitions on OS Disk     | `false`                                  |
| `crd.enableInstall`                     | Enable installation of CRDs by OpenEBS        | `true`                                    |
| `policies.monitoring.image`             | Image for Prometheus Exporter                 | `openebs/m-exporter`                      |
| `policies.monitoring.imageTag`          | Image Tag for Prometheus Exporter             | `2.10.0`                                  |
| `analytics.enabled`                     | Enable sending stats to Google Analytics      | `true`                                    |
| `analytics.pingInterval`                | Duration(hours) between sending ping stat     | `24h`                                     |
| `defaultStorageConfig.enabled`          | Enable default storage class installation     | `true`                                    |
| `varDirectoryPath.baseDir`              | To store debug info of OpenEBS containers     | `/var/openebs`                            |
| `healthCheck.initialDelaySeconds`       | Delay before liveness probe is initiated      | `30`                                      |
| `healthCheck.periodSeconds`             | How often to perform the liveness probe       | `60`                                      |
| `cleanup.image.registry`                | Cleanup pre hook image registry               | `nil`                                     |
| `cleanup.image.repository`              | Cleanup pre hook image repository             | `"bitnami/kubectl"`                       |
| `cleanup.image.tag`                     | Cleanup pre hook image tag             | `if not provided determined by the k8s version`                       |
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
helm install --name openebs -f values.yaml openebs/openebs
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Below charts are dependent charts of this chart
-  [openebs-ndm](https://openebs.github.io/node-disk-manager)
-  [localpv-provisioner](https://openebs.github.io/dynamic-localpv-provisioner)
-  [cstor](https://openebs.github.io/cstor-operators)
-  [jiva](https://openebs.github.io/jiva-operator)
-  [zfs-localpv](https://openebs.github.io/zfs-localpv)
-  [lvm-localpv](https://openebs.github.io/lvm-localpv)

## Dependency tree of this chart
```bash
openebs
├── openebs-ndm
├── localpv-provisioner
│   └── openebs-ndm (optional)
├── jiva
│   └── localpv-provisioner
│       └── openebs-ndm (optional)
├── cstor
│   └── openebs-ndm
├── zfs-localpv
└── lvm-localpv
```

#### (Default) Install Jiva, cStor and Local PV with out-of-tree provisioners
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace
```

#### Install cStor with CSI driver
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace \
--set localprovisioner.enabled=false \
--set ndm.enabled=false \
--set ndmOperator.enabled=false \
--set webhook.enabled=false \
--set snapshotOperator.enabled=false \
--set provisioner.enabled=false \
--set apiserver.enabled=false \
--set cstor.enabled=true \
--set openebs-ndm.enabled=true
```

#### Install Jiva with CSI driver
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace \
--set localprovisioner.enabled=false \
--set ndm.enabled=false \
--set ndmOperator.enabled=false \
--set webhook.enabled=false \
--set snapshotOperator.enabled=false \
--set provisioner.enabled=false \
--set apiserver.enabled=false \
--set jiva.enabled=true \
--set openebs-ndm.enabled=true \
--set localpv-provisioner.enabled=true
```

#### Install ZFS Local PV
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace \
--set localprovisioner.enabled=false \
--set ndm.enabled=false \
--set ndmOperator.enabled=false \
--set webhook.enabled=false \
--set snapshotOperator.enabled=false \
--set provisioner.enabled=false \
--set apiserver.enabled=false \
--set zfs-localpv.enabled=true
```

#### Install LVM Local PV
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace \
--set localprovisioner.enabled=false \
--set ndm.enabled=false \
--set ndmOperator.enabled=false \
--set webhook.enabled=false \
--set snapshotOperator.enabled=false \
--set provisioner.enabled=false \
--set apiserver.enabled=false \
--set lvm-localpv.enabled=true
```

#### Install Local PV hostpath and device
```bash
helm install openebs openebs/openebs --namespace openebs --create-namespace \
--set localprovisioner.enabled=false \
--set ndm.enabled=false \
--set ndmOperator.enabled=false \
--set openebs-ndm.enabled=true \
--set localpv-provisioner.enabled=true
```

> **Tip**: You can install multiple csi driver by merging the configuration.
