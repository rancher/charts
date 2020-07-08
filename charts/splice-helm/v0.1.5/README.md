# Splice Machine Database Helm Chart

Deploy a single instance of Splice Machine Database

This Helm Chart requires the use of Helm v2.x.

## Prerequisites

- Kubernetes 1.14, 1.15
- Kubernetes cluster that provides PV/PVC with read write access
- Apply storage classes to the Kubernetes cluster
- SSL Certificate (tls.crt and tls.key)

### Storage Classes Required

We have defined several storage classes to help manage cost/performance balance.

- Classes
  - splicedb-premium
  - splicecore-premium
  - splice-hdd-delete
  - splice-hdd-retain
  - splice-file-storage

See the `Storage Class Examples` section below for some example definitions.

## Configuration

This table lists the most used configuration parameters from the various values.yaml files.

| Parameter                                            | Description                                                       | Default Value |
| ---------------------------------------------------- | ----------------------------------------------------------------- | ------------- |
| `global.environmentName`                             | Environment name for the cluster: dev/qa/prod                     | `dev`         |
| `global.dnsPrefix`                                   | Value to prefix all DNS entries with                              | empty         |
| `global.certificateName`                             | The domain of the certificate being used                          | empty         |
| `tls-secret.condition.installCertificate.enabled`    | Set if you want to provide a certificate                          | `true`        |
| `global.tls.crt`                                     | The contents of a tls.crt file                                    | user provided |
| `global.tls.key`                                     | The contents of a tls.key file                                    | user provided |
| `hadoop.dataNode.persistent.size`                    | Size of the hadoop volumes                                        | `1T`          |
| `hadoop.dataNode.replicas`                           | Number of hadoop data nodes                                       | `3`           |
| `hbase.region.replicas`                              | Number of hbase region nodes, recommend same as hadoop data nodes | `3`           |
| `jupyterhub.singleuser.extraEnv.SPARKEXECUTOR_COUNT` | Spark executors for JupyterHub notebooks                          | `2`           |
| `global.splice.password`                             | Password for the default `splice` account                         | `admin`       |

## Installation

### Command line parameters method

```shell
helm install --name splicedb --namespace splice splicemachine/splice-helm \
  --set global.environmentName=dev1 \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=dev.example.io \
  --set tls-secret.condition.installCertificate.enabled=true \
  --set-string global.tls.crt="$(cat ./tls.crt)" \
  --set-string global.tls.key="$(cat ./tls.key)"
```

### Edit values file method

There is a values_required.yaml file, this can be edited and each of the keys
needs to have a value provided.  Once the files is edited, the installation can be
performed using:

```shell
# this will fetch and untar the chart into a directory named `splice-helm`
helm fetch splicemachine/splice-helm --untar
cd splice-helm
# edit the values_required.yaml file
helm install --name splicedb --namespace splice -f values_required.yaml .
```

### Rancher Method

When choosing `Launch` from the `Apps` menu, locate the `splice-helm` application from the Rancher library.

Supply the release name and namespace, we generally make this the same.

In the `General` section, the environment name and dns prefix are both used to build host names that are used
to route traffic via nginx and haproxy.  The format can be found below in the information about [Nginx
Ingress Controller](#nginx-ingress-controller).

If you would like the Rancher application to install the TLS certificate, choose to `Install TLS Certificate`
and paste the contents of your tls.crt and tls.key files into the `Certificate Data` and `Certificate Private Key`
fields.

In the `Database Credentials` section, enter the password to be assignd to the default `splice` user.

The `Optional` section allows you to specify the persistent volume size for each of the Hadoop Data Nodes.
Also selected here is the number of Hadoop Data Nodes and Hbase Region Servers.  These latter two are usually
set to the same as they have affinity rules to pair Data Nodes and Region Server Statefulset Pods on the same
Kubernetes nodes.

Once the data is provided, click Launch and wait for the application to become `active`.

## Post Install Configuration

### DNS

There are multiple services that will have public facing IP addresses.

- splicedb-haproxy-controller
- splicedb-kafka-external-0
- splicedb-nginx-ingress-controller

#### HA Proxy Controller

This service provides JDBC connectivity to the database on port 1527.  Generally we configure
the DNS host entry using the following format:

`jdbc-{dnsPrefix}-{environmentName}.{domain}`

Where {domain} is the domain specified in the `global.certificateName` setting.

#### Kafka External

This provides Kafka streaming on port 19092.  Generally we configure the DNS host entry using the
following format:

`kafka-broker-0-{dnsPrefix}-{environmentName}.{domain}`

#### Nginx Ingress Controller

This is our primary ingress for UI administrative pages.  Unlike the JDBC and Kafka DNS host names,
this format is required in order to properly route traffic to the correct pages.

| Host Name                                           | Path            | Backend UI            |
| --------------------------------------------------- | --------------- | --------------------- |
| `{dnsPrefix}-{environmentName}.{domain}`            | /splicejupyter/ | Jupyter Hub Notebooks |
|                                                     | /mlflow/        | ML Flow UI            |
| `{dnsPrefix}-{environmentName}admin-hdfs.{domain}`  | /               | HDFS Admin UI         |
| `{dnsPrefix}-{environmentName}admin-hbase.{domain}` | /               | Hbase Admin UI        |
| `{dnsPrefix}-{environmentName}-spark.{domain}`      | /               | Spark UI              |
| `{dnsPrefix}-{environmentName}-jobtracker.{domain}` | /               | Job Tracker UI        |
| `{dnsPrefix}-{environmentName}-kafka.{domain}`      | /               | Kafka UI              |

## Using Splice Machine Database

The documentation for Splice Machine, [doc.splicemachine.com](https://doc.splicemachine.com/).
The documentation for [Connecting](https://doc.splicemachine.com/connecting_intro.html#BITools) to the database.
Our CLI, sqlshell, used to connect to the database can be downloaded [here](https://splice-releases.s3.amazonaws.com/3.0.0.1947/cluster/sqlshell/sqlshell-3.0.0.1947.tar.gz).

## Uninstall

```shell
helm delete splicedb --purge
```

## Storage Class Examples

### Example Storage Classes for AWS

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicedb-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicecore-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-delete
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: sc1
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-retain
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: sc1
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-file-storage
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Example Storage Classes for Azure

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicedb-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/azure-disk
parameters:
  cachingmode: ReadOnly
  kind: Managed
  storageaccounttype: Premium_LRS
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicecore-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/azure-disk
parameters:
  cachingmode: ReadOnly
  kind: Managed
  storageaccounttype: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-delete
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/azure-disk
parameters:
  cachingmode: ReadOnly
  kind: Shared
  storageaccounttype: Standard_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-retain
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/azure-disk
parameters:
  cachingmode: ReadOnly
  kind: Shared
  storageaccounttype: Standard_LRS
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-file-storage
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/azure-file
parameters:
  skuName: Standard_LRS
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - mfsymlinks
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

### Example Storage Classes for GCP

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicedb-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicecore-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-delete
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: none
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-retain
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: none
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-file-storage
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: none
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Example Storage Classes for Openstack/Cinder

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicedb-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splicecore-premium
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-delete
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-hdd-retain
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Retain
volumeBindingMode: Immediate
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: splice-file-storage
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Retain
volumeBindingMode: Immediate
```
