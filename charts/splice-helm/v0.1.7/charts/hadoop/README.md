# Hadoop

This helm chart provides an implementation of an HA HDFS specifically it creates journal nodes, name nodes and data nodes.  More details about hdfs can be found [here](https://hadoop.apache.org/).

## Chart Components

The chart will create the following:

* Creates a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) to be used by all hdfs pods and some hbase pods.  It contains the custom configuration for core-site.xml and hdfs-site.xml

1. `configMap/xxxx-hadoop-config` is the contents of the config map

### Journal Nodes

High-availabilty clusters use JournalNodes to synchronize active and standby NameNodes. The active NameNode writes to each JournalNode with changes, or "edits," to HDFS namespace metadata. During failover, the standby NameNode applies all edits from the JournalNodes before promoting itself to the active state.

* Create a fixed size Journal Node ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) 
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the Journal ensemble.
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the Quorum size of the ensemble.
* Applies a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to spread the Journal Nodes across nodes.

1. `statefulsets/xxx-hdfs-jn` is the StatefulSet created by the chart.
2. `pod/xxx-hdfs-jn-<0|1|2>` are the Pods created by the StatefulSet. Each Pod has a single container running a Journal server.
3. `svc/xxx-hdfs-jn` is the Headless Service used to control the network domain of the Journal ensemble.

### Name Nodes

NameNodes maintain the namespace tree for HDFS and a mapping of file blocks to DataNodes where the data is stored.  A high availability cluster contains two NameNodes: active and standby.

* Create a fixed size HA Name Node servers using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) 
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the name nodes.
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the name nodes properly.
* Applies a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to spread the Data Nodes  across nodes.
* Create a Service configured to connect to the available Web User Interface.

1. `statefulsets/xxx-hdfs-nn` is the StatefulSet created by the chart.
2. `pod/xxx-hdfs-nn-<0|1>` are the Pods created by the StatefulSet. Each Pod has a single container running a data node server.
3. `svc/xxx-hdfs-nn-headless` is the Headless Service used to control the network domain of the data nodes.
4. `svc/xxx-hdfs-nn` is the Service configured to connect to the available Web User Interface.

### Data Nodes

DataNodes store data in a Hadoop cluster and is the name of the daemon that manages the data. File data is replicated on multiple DataNodes for reliability and so that localized computation can be executed near the data. The default replication factor for HDFS is three. That is, three copies of data are maintained at all times.

* Create a configurable set of Data Node servers using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) 
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the data nodes.
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the data nodes properly.
* Applies a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to spread the Data Nodes  across nodes.

1. `statefulsets/xxx-hdfs-dn` is the StatefulSet created by the chart.
2. `pod/xxx-hdfs-dn-<0|1|2|...>` are the Pods created by the StatefulSet. Each Pod has a single container running a data node server.
3. `svc/xxx-hdfs-dn` is the Headless Service used to control the network domain of the data nodes.

## Installing the Chart

This chart would typically be installed as a part of a parent chart.  All values are specified in the parent chart values.yaml file.

## Configuration - Global

The following table lists the global configurable parameters of the Hadoop chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `image.registry`                                  | Where the Docker file is registered at                                             | `docker.io`                                                           |
| `image.repository`                                | Zookeeper image                                                                    | `splicemachine/splice_hdfs`                                |
| `image.tag`                                       | Zookeeper image tag                                                                | `1.0.0`                                                               |
| `image.pullPolicy`                                | Pull policy for the images                                                         | `Always`     | `image.pullSecrets`                               | The secret to used to connect to the image.registry                                | `regcred`                                                             |

## Configuration - Common

The values.yaml file has 3 subsections (nameNode, journalNode and dataNode) under the hadoop subchart.  In each subsections the following configurable parameters are available:

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `livenessProbe.initialDelaySeconds`               | Number of seconds after a container has started before probe are initiated         | `120`                                                                 |
| `livenessProbe.periodSeconds`                     | How often in seconds to perform the check                                          | `10`                                                                  |
| `livenessProbe.timeoutSeconds`                    | Number of seconds after which the probe times out.                                 | `5`                                                                   |
| `livenessProbe.failureThreshold`                  | Number of times to try the probe before restarting the POD                         | `6`                                                                   |
| `livenessProbe.successThreshold`                  | Minimum consecutive successes to be considered successful after having failed      | `1`                                                                   |
| `persistence.accessMode`                          | Descriptors of the volume’s capabilities.  Valid values: ReadWriteOnce,ReadOnlyMany,ReadWriteMany  | `ReadWriteOnce`                                       |
| `persistence.size`                                |  The size of disk for persistent storage                                           | `1Gi`                                                                |
| `readinessProbe.initialDelaySeconds`              | Number of seconds after a container has started before probe are initiated         | `30`                                                                  |
| `readinessProbe.periodSeconds`                    | How often in seconds to perform the check                                          | `10`                                                                  |
| `readinessProbe.timeoutSeconds`                   | Number of seconds after which the probe times out.                                 | `5`                                                                   |
| `readinessProbe.failureThreshold`                 | Number of times to try the probe before putting the pod in Unready state           | `6`                                                                   |
| `readinessProbe.successThreshold`                 | Minimum consecutive successes to be considered successful after having failed      | `1`                                                                   |
| `resources.requests.memory`                       | The amount of memory that a container needs                                        | `1Gi`                                                                 |
| `resources.requests.cpu`                          | The amount of CPU that a container needs                                           | `0.5`                                                                 |

## Configuration - Remaining

The following table lists the remaining configurable parameters of the Hadoop chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `serviceName`                                     | The name of the hadoop service.  Used for display purposes only                    | `hdfs`                                                                |
| `antiAffinity`                                    | There are 2 types of rules - hard and soft.  Hard means the affinity rule must be respected and Soft means it should be respected  | `soft`              |
| `dataNode.dataDir`                                | The mount directory for the disks.  Corresponds to the dfs.datanode.data.dir       | `/data-data`                                                          |
| `dataNode.pdbMinAvailable`                        | Number of pods that must be available.  It is an integer.                          | `1`                                                                   |
| `dataNode.replicaCount`                           | Number of pod instances to create.  This should not be changed                     | `3`                                                                   |
| `journalNode.dataDir`                             | The mount directory for the disks.  Also used for the dfs.journalnode.edits.dir property                   | `/journal-data`                               |
| `journalNode.replicaCount`                        | Number of pod instances to create.  This should not be changed                     | `3`                                                                   |
| `journalNode.pdbMinAvailable`                     | Number of pods that must be available.  It is an integer.  Must be 1               | `1`                                                                   |
| `nameNode.dataDir`                                | The mount directory for the disks.  Also used for the dfs.namenode.name.dir property                   | `/journal-data`                                   |
| `nameNode.pdbMinAvailable`                        | Number of pods that must be available.  It is an integer.  Must be 1               | `1`                                                                   |
| `nameNode.ports.dfs`                              | The port for the dfs                                                               | `8020`                                                                |
| `nameNode.ports.webhdfs`                          | Number of pods that must be available.  It is an integer.  Must be 1               | `50070`                                                               |

## Deep Dive

### Image Details

The image used for this chart is based on centos:7.4.1708. The Dockerfile can be found [here](https://github.com/splicemachine/dbaas-infrastructure/blob/master/deploy/docker/splicemachine/hdfs/Dockerfile).

### JVM Details

The Java Virtual Machine used for this chart is the jdk-8u121-linux-x64.

### Hadoop Details

The Hadoop version is the latest stable version (2.8.5). The distribution is installed into /opt/hadoop. 
