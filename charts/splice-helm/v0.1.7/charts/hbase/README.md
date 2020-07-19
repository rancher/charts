# Hbase Chart

This helm chart provides an implementation of an HA HBase specifically it creates master nodes and region servers.  More details about hbase can be found [here](https://hbase.apache.org/).

## Components

### Master Server

Region assignment, DDL (create, delete tables) operations are handled by the HBase Master.

* Coordinating the region servers
  * Assigning regions on startup , re-assigning regions for recovery or load balancing
  * Monitoring all RegionServer instances in the cluster (listens for notifications from zookeeper)
* Admin functions
  * Interface for creating, deleting, updating tables

### Region Server 
A Region Server runs on an HDFS data node and has the following components:

* WAL: Write Ahead Log is a file on the distributed file system. The WAL is used to store new data that hasn't yet been persisted to permanent storage; it is used for recovery in the case of failure.
* BlockCache: is the read cache. It stores frequently read data in memory. Least Recently Used data is evicted when full.
* MemStore: is the write cache. It stores new data which has not yet been written to disk. It is sorted before writing to disk. There is one MemStore per column family per region.
* Hfiles store the rows as sorted KeyValues on disk.

## Chart Components

The chart will create the following:

* Creates a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) to be used by all hbase pods.  It contains the custom configuration for hbase-site.xml and hbase-env.sh

1. `configMap/xxxx-hbase-config` is the contents of the config map

### Master Nodes

* Create a fixed size HA Name Node servers using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) 
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the master nodes.
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the master nodes properly.
* Applies a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to spread the master Nodes  across nodes.
* Create a Service configured to connect to the available Web User Interface.

1. `statefulsets/xxx-hmaster` is the StatefulSet created by the chart.
2. `pod/xxx-hmaster-<0|1>` are the Pods created by the StatefulSet. Each Pod has a single container running a master node server.
3. `svc/xxx-hmaster-headless` is the Headless Service used to control the network domain of the master nodes.
4. `svc/xxx-hmaster` is the Service configured to connect to the available Web User Interface.

### Region Server Nodes

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

The following table lists the global configurable parameters of the Hbase chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `config`                                          | This is a main section that has several subvariables for the hbase configuration   | `Too many to list`                                                    |
| `image.registry`                                  | Where the Docker file is registered at                                             | `docker.io`                                                           |
| `image.repository`                                | Zookeeper image                                                                    | `splicemachine/splice_hbase`                             |
| `image.tag`                                       | Zookeeper image tag                                                                | `1.0.0`                                                               |
| `image.pullPolicy`                                | Pull policy for the images                                                         | `Always`     | `image.pullSecrets`                               | The secret to used to connect to the image.registry                                | `regcred`                                                             |

## Configuration - Common

The values.yaml file has 2 subsections (master and region) under the hbase subchart.  In each subsections the following configurable parameters are available:

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `livenessProbe.initialDelaySeconds`               | Number of seconds after a container has started before probe are initiated         | `120`                                                                 |
| `livenessProbe.periodSeconds`                     | How often in seconds to perform the check                                          | `10`                                                                  |
| `livenessProbe.timeoutSeconds`                    | Number of seconds after which the probe times out.                                 | `5`                                                                   |
| `livenessProbe.failureThreshold`                  | Number of times to try the probe before restarting the POD                         | `6`                                                                   |
| `livenessProbe.successThreshold`                  | Minimum consecutive successes to be considered successful after having failed      | `1`                                                                   |
| `readinessProbe.initialDelaySeconds`              | Number of seconds after a container has started before probe are initiated         | `30`                                                                  |
| `readinessProbe.periodSeconds`                    | How often in seconds to perform the check                                          | `10`                                                                  |
| `readinessProbe.timeoutSeconds`                   | Number of seconds after which the probe times out.                                 | `5`                                                                   |
| `readinessProbe.failureThreshold`                 | Number of times to try the probe before putting the pod in Unready state           | `6`                                                                   |
| `readinessProbe.successThreshold`                 | Minimum consecutive successes to be considered successful after having failed      | `1`                                                                   |
| `resources.requests.memory`                       | The amount of memory that a container needs                                        | `1Gi`                                                                 |
| `resources.requests.cpu`                          | The amount of CPU that a container needs                                           | `0.5`                                                                 |
| `replicas`                                        | The number of pods to created.                                                     | `master:2, region: 3`                                               |
| `pdbMinAvailable`                                 | Number of pods that must be available.  It is an integer.                          | `1`                                                                   |

## Deep Dive

### Image Details

The image used for this chart is based on centos:7.4.1708. The Dockerfile can be found [here](https://github.com/splicemachine/dbaas-infrastructure/blob/master/deploy/docker/splicemachine/hbase/Dockerfile).

### JVM Details

The Java Virtual Machine used for this chart is the jdk-8u121-linux-x64.

### HBase Details

The ZooKeeper version is the latest stable version (2.2.0). The distribution is installed into /opt/hbase. 
