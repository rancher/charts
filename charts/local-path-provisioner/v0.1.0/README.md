# Local Path Provisioner

[Local Path Provisioner](https://github.com/rancher/local-path-provisioner) provides a way for the Kubernetes users to
utilize the local storage in each node. Based on the user configuration, the Local Path Provisioner will create
`hostPath` based persistent volume on the node automatically. It utilizes the features introduced by Kubernetes [Local
Persistent Volume feature](https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/), but make it a simpler
solution than the built-in `local` volume feature in Kubernetes.

This Helm Chart is based on the [official local-path-provisioner chart](https://github.com/rancher/local-path-provisioner/tree/master/deploy/chart) and on previous work on the [Interlegis local-path-provisioner chart](https://github.com/interlegis/il-charts/tree/master/local-path-provisioner). 

## Introduction

This chart bootstraps a [Local Path Provisioner](https://github.com/rancher/local-path-provisioner) deployment on a
[Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+ with Beta APIs enabled

## Configuration

The following table lists the configurable parameters of the Local Path Provisioner for Kubernetes chart and their
default values.

| Parameter                           | Description                                                                     | Default                                                                             |
| ----------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `image.repository`                  | Local Path Provisioner image name                                               | `rancher/local-path-provisioner`                                                    |
| `image.tag`                         | Local Path Provisioner image tag                                                | `v0.0.18`                                                                           |
| `image.pullPolicy`                  | Image pull policy                                                               | `IfNotPresent`                                                                      |
| `storageClass.create`               | If true, create a `StorageClass`                                                | `true`                                                                              |
| `storageClass.provisionerName`      | The provisioner name for the storage class                                      | `nil`                                                                               |
| `storageClass.defaultClass`         | If true, set the created `StorageClass` as the cluster's default `StorageClass` | `false`                                                                             |
| `storageClass.name`                 | The name to assign the created StorageClass                                     | local-path                                                                          |
| `storageClass.reclaimPolicy`        | ReclaimPolicy field of the class                                                | Delete                                                                              |
| `storageClass.hostDir`              | Default host path for volumes. Ignored if using customNodePathMap.              | `/opt/local-path-provisioner`                                                       |
| `customNodePathMap`                 | Custom configuration of where to store the data on each node                    | `[]`                                                                                |
| `resources`                         | Local Path Provisioner resource requests & limits                               | `{}`                                                                                |
| `rbac.create`                       | If true, create & use RBAC resources                                            | `true`                                                                              |
| `serviceAccount.create`             | If true, create the Local Path Provisioner service account                      | `true`                                                                              |
| `serviceAccount.name`               | Name of the Local Path Provisioner service account to use or create             | `nil`                                                                               |
| `nodeSelector`                      | Node labels for Local Path Provisioner pod assignment                           | `{}`                                                                                |
| `tolerations`                       | Node taints to tolerate                                                         | `[]`                                                                                |
| `affinity`                          | Pod affinity                                                                    | `{}`                                                                                |
| `configmap.setup`                   | Configuration of script to execute setup operations on each node                | #!/bin/sh<br>while getopts "m:s:p:" opt<br>do<br>&emsp;case $opt in <br>&emsp;&emsp;p)<br>&emsp;&emsp;absolutePath=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;&emsp;s)<br>&emsp;&emsp;sizeInBytes=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;&emsp;m)<br>&emsp;&emsp;volMode=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;esac<br>done<br>mkdir -m 0777 -p ${absolutePath}                                    |
| `configmap.teardown`                | Configuration of script to execute teardown operations on each node             | #!/bin/sh<br>while getopts "m:s:p:" opt<br>do<br>&emsp;case $opt in <br>&emsp;&emsp;p)<br>&emsp;&emsp;absolutePath=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;&emsp;s)<br>&emsp;&emsp;sizeInBytes=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;&emsp;m)<br>&emsp;&emsp;volMode=$OPTARG<br>&emsp;&emsp;;;<br>&emsp;esac<br>done<br>rm -rf ${absolutePath}                                              |
| `configmap.name`                    | configmap name                                                                  | `local-path-config`                                                                 |
| `configmap.helperPod`               | helper pod yaml file                                                            | apiVersion: v1<br>kind: Pod<br>metadata:<br>&emsp;name: helper-pod<br>spec:<br>&emsp;containers:<br>&emsp;- name: helper-pod<br>&emsp;&emsp;image: busybox |

