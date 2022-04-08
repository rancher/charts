# Splice Machine Database Helm Chart

Deploy a single instance of Splice Machine Database

This Helm Chart requires the use of Helm v2.x.

## TL;DR

At a minimum you'll want to have a domain name you can create DNS records for, and a working
Kubernetes cluster.

```shell
DOMAIN_NAME={your domain name}  # dev.example.io
helm install --name splicedb --namespace splice splicemachine/splice-helm \
  --set-string global.certificateName=${DOMAIN_NAME}
```

Read the installation notes section below while your Splice Machine database is being provisioned.

## Prerequisites

- Kubernetes 1.14, 1.15, 1.16, 1.17
- Kubernetes cluster that provides PV/PVC with read write access
- Apply storage classes to the Kubernetes cluster
- SSL Certificate (tls.crt and tls.key)

## Installation Notes

While it IS possible to simply install Splice Machine (splice-helm) Chart without providing any
parameters, there are some caveats that need to be taken into consideration:

- The default domain name will be `dev.splicemachine-dev.io`
- Web UI endpoints will not have a valid SSL certificate
- All storage disks will be provisioned using the `default` storage class
  - Storage access speeds have a direct correlation to the performance of a Splice Machine database.

Please stop by our [Slack](https://splicemachine.slack.com) channel #splice-community.  We would be
happy to assist in the deployment of our Helm chart.

## Configuration

This table lists the most used configuration parameters from the various values.yaml files.

| Parameter                                            | Description                                                       | Default Value              |
| ---------------------------------------------------- | ----------------------------------------------------------------- | -------------------------- |
| `global.environmentName`                             | Environment name for the cluster: dev/qa/prod                     | `dev1`                     |
| `global.dnsPrefix`                                   | Value to prefix all DNS entries with                              | `splicedb`                 |
| `global.certificateName`                             | The domain of the certificate being used                          | `dev.splicemachine-dev.io` |
| `global.tls.enabled`                                 | Set if you want to provide a certificate                          | `false`                    |
| `global.tls.crt`                                     | The contents of a tls.crt file                                    | user provided              |
| `global.tls.key`                                     | The contents of a tls.key file                                    | user provided              |
| `hadoop.dataNode.persistent.size`                    | Size of the hadoop volumes                                        | `.2T`                      |
| `hadoop.dataNode.replicas`                           | Number of hadoop data nodes                                       | `3`                        |
| `hbase.region.replicas`                              | Number of hbase region nodes, recommend same as hadoop data nodes | `3`                        |
| `jupyterhub.singleuser.extraEnv.SPARKEXECUTOR_COUNT` | Spark executors for JupyterHub notebooks                          | `2`                        |
| `global.splice.password`                             | Password for the default `splice` account                         | `admin`                    |

## Installation

### Add Splice Machine Helm Repository

This needs to be run one time.

```shell
helm repo add splicemachine https://splicemachine.github.io/charts
helm repo update
```

### Command line parameters method

See the Advanced Installation section for more configuration scenarios.

```shell
DOMAIN_NAME=dev.splicemachine-dev.io  # change this to a domain name you own and have access to create/update DNS records
ENVIRONMENT=dev                       # identifier for the environment, reflected in DNS host names
DNSPREFIX=splice                      # name to prefix DNS host name with "splice-...."
helm install --name splicedb --namespace splice splicemachine/splice-helm \
  --set global.environmentName=${ENVIRONMENT} \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=${DOMAIN_NAME}
```

The command to install using a valid SSL certificate.

```shell
DOMAIN_NAME=dev.splicemachine-dev.io  # change this to a domain name you own and have access to create/update DNS records
ENVIRONMENT=dev                       # identifier for the environment, reflected in DNS host names
DNSPREFIX=splice                      # name to prefix DNS host name with "splice-...."
helm install --name splicedb --namespace splice splicemachine/splice-helm \
  --set-string global.environmentName=${ENVIRONMENT} \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=${DOMAIN_NAME} \
  --set global.tls.enabled=true \
  --set-string global.tls.crt=$(cat tls.crt) \
  --set-string global.tls.key=$(cat tls.key)
```

#### Certificate Files

The tls.crt file will have contents that contain

```plaintext
-----BEGIN CERTIFICATE-----
{certificate encoded data}
-----END CERTIFICATE-----
```

And the `tls.key` file will have contents that contain

```plaintext
-----BEGIN PRIVATE KEY-----
{encoded private key}
-----END PRIVATE KEY-----
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
| `{dnsPrefix}-{environmentName}admin-hbase.{domain}` | /               | HBASE Admin UI        |
| `{dnsPrefix}-{environmentName}-spark.{domain}`      | /               | Spark UI              |
| `{dnsPrefix}-{environmentName}-jobtracker.{domain}` | /               | Job Tracker UI        |
| `{dnsPrefix}-{environmentName}-kafka.{domain}`      | /               | Kafka UI              |

## Using Splice Machine Database

The documentation for Splice Machine, [doc.splicemachine.com](https://doc.splicemachine.com/).
The documentation for [Connecting](https://doc.splicemachine.com/connecting_intro.html#BITools) to the database.
Our CLI, sqlshell, used to connect to the database can be downloaded [here](https://splice-releases.s3.amazonaws.com/3.0.0.1947/cluster/sqlshell/sqlshell-3.0.0.1947.tar.gz)

Our Jupyter Notebooks contain a walkthrough of our database functionality.  Connect to the `splicejupyter` URL as described above, logging in with the `splice` user and
database password provided during the provisioning of the database.

## Uninstall

```shell
helm delete splicedb --purge
```

## Advanced Setup

Like any advanced database system, there is advanced configuration that will allow you to get the
most out of a Splice Machine database.  Here we will cover the use of Node Selectors and Storage Classes.

### Node Selector Definitions

The splice-helm Helm chart supports assigning specific workloads to Kubernetes Nodes that match a label.
Our label name is `components`.  Using this configuration we can specify workloads that support reading
and writing data to the database to be placed on high-powered Nodes, and workloads that are in support
of running the database engine to less expensive Nodes.

Our platform supports two different node groups in order to provide the correct sizing to each sub-component of our platform.

| components | Size of Node       |
| ---------- | ------------------ |
| db         | Large Sized Nodes  |
| meta       | Medium Sized Nodes |

Nodes can be tagged with a the `components` label using the following command:

```shell
NODE_NAME=node-name
# add the "db" label
kubectl patch node ${NODE_NAME} -p '{"metadata":{"labels":{"components":"db"}}}'
# add the "meta" label
kubectl patch node ${NODE_NAME} -p '{"metadata":{"labels":{"components":"meta"}}}'
```

We can enable the use of Node Selectors by enabling Node Selectors.

```shell
DOMAIN_NAME=dev.splicemachine-dev.io  # change this to a domain name you own and have access to create/update DNS records
ENVIRONMENT=dev                       # identifier for the environment, reflected in DNS host names
DNSPREFIX=splice                      # name to prefix DNS host name with "splice-...."
helm install --name splicedb --namespace splice splicemachine/splice-helm \
  --set global.environmentName=${ENVIRONMENT} \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=${DOMAIN_NAME} \
  --set global.nodeSelector.enabled=true
```

### Storage Class Definitions

We have defined storage classes to help manage cost/performance balance.

| Storage Class Name  | Usage Detail                          |
| ------------------- | ------------------------------------- |
| splicedb-premium    | High IOPS, Retain upon PVC deletion   |
| splice-file-storage | General Use, Retain upon PVC deletion |

See the `Storage Class Examples` section below for some example definitions.
Create a yaml file `storage_classes.yaml` from one of the examples below and
modify to fit your Kubernetes implementation.  Create the new Kubernetes resources:

```shell
kubectl create -f storage_classes.yaml
```

Once your Kubernetes cluster has the storage classes added, you can activate their
use by either including the `storageclass_values.yaml` file using the `-f` option or by specifying
each option on the command line via `--set-string` options.

#### Additional values file option

```shell
helm fetch splicemachine/splice-helm --untar
cd splice-helm
DOMAIN_NAME=dev.splicemachine-dev.io  # change this to a domain name you own and have access to create/update DNS records
ENVIRONMENT=dev                       # identifier for the environment, reflected in DNS host names
DNSPREFIX=splice                      # name to prefix DNS host name with "splice-...."
helm install --name splicedb --namespace splice . \
  --set global.environmentName=${ENVIRONMENT} \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=${DOMAIN_NAME} \
  -f storageclass_values.yaml
```

#### set-string option

```shell
helm fetch splicemachine/splice-helm --untar
cd splice-helm
DOMAIN_NAME=dev.splicemachine-dev.io  # change this to a domain name you own and have access to create/update DNS records
ENVIRONMENT=dev                       # identifier for the environment, reflected in DNS host names
DNSPREFIX=splice                      # name to prefix DNS host name with "splice-...."
helm install --name splicedb --namespace splice . \
  --set global.environmentName=${ENVIRONMENT} \
  --set-string global.dnsPrefix=splice \
  --set-string global.certificateName=${DOMAIN_NAME} \
  --set-string hadoop.dataNode.persistence.storageClassName=splicedb-premium \
  --set-string hbase.master.persistence.storageClassName=splice-file-storage \
  --set-string hbase.region.persistence.storageClassName=splice-file-storage \
  --set-string hbase.olap.persistence.storageClassName=splice-file-storage \
  --set-string kafka.persistence.storageClassName=splicedb-premium
```

### Storage Class Examples

#### Example Storage Classes for AWS

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

#### Example Storage Classes for Azure

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

#### Example Storage Classes for GCP

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

#### Example Storage Classes for Openstack/Cinder

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
  name: splice-file-storage
  labels:
    app: splice-storageclass
provisioner: kubernetes.io/cinder
reclaimPolicy: Retain
volumeBindingMode: Immediate
```
