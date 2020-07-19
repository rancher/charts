# zookeeper

This helm chart provides an implementation of ZooKeeper.  Zookeeper is used to store state information for HDFS, HBase and Splice Machine.  More details about zookeeper can be found [here](https://zookeeper.apache.org/).

## Chart Components

The charts will create the following:

* Create a fixed size ZooKeeper ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) 
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the ZooKeeper ensemble.
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the Quorum size of the ensemble.
* Create a Service configured to connect to the available ZooKeeper instance on the configured client port.
* Applies a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to spread the ZooKeeper ensemble across nodes.

1. `statefulsets/zookeeper` is the StatefulSet created by the chart.
2. `pod/zookeeper-<0|1|2>` are the Pods created by the StatefulSet. Each Pod has a single container running a ZooKeeper server.
3. `svc/zookeeper-headless` is the Headless Service used to control the network domain of the ZooKeeper ensemble.
4. `svc/zookeeper` is a Service that can be used by clients to connect to an available ZooKeeper server.

## Installing the Chart

This chart would typically be installed as a part of a parent chart.  All values are specified in the parent chart values.yaml file.

## Configuration

The following table lists the configurable parameters of the Zookeeper chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `dataDirMountPath`                                | The directory where the persistent storage should be mounted                       | `/var/lib/zookeeper`                                               |
| `image.registry`                                  | Where the Docker file is registered at                                             | `docker.io`                                                           |
| `image.repository`                                | Zookeeper image                                                                    | `splicemachine/zookeeper`                                |
| `image.tag`                                       | Zookeeper image tag                                                                | `1.0.0`                                                               |
| `image.pullPolicy`                                | Pull policy for the images                                                         | `IfNotPresent`                                           |
| `image.pullSecrets`                               | The secret to used to connect to the image.registry                                | `regcred`                                                             |
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
| `replicatCount`                                   | Number of pod instances to create.  This should not be changed                     | `3`                                                                   |
| `resources.requests.memory`                       | The amount of memory that a container needs                                        | `1Gi`                                                                 |
| `resources.requests.cpu`                          | The amount of CPU that a container needs                                           | `0.5`                                                                 |

## Deep Dive

### Image Details

The image used for this chart is based on centos:7.4.1708. The Dockerfile can be found [here](https://github.com/splicemachine/dbaas-infrastructure/blob/master/deploy/docker/splicemachine/zookeeper/Dockerfile).

### JVM Details

The Java Virtual Machine used for this chart is the jdk-8u121-linux-x64.

### ZooKeeper Details

The ZooKeeper version is the latest stable version (3.4.10). The distribution is installed into /opt/zookeeper. 

## Failover

You can test failover by killing the leader. Insert a key:

```console
$ kubectl exec zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar;
$ kubectl exec zookeeper-2 -- /opt/zookeeper/bin/zkCli.sh get /foo;
```

Watch existing members:

```console
$ kubectl run --attach bbox --image=busybox --restart=Never -- sh -c 'while true; do for i in 0 1 2; do echo zk-${i} $(echo stats | nc <pod-name>-${i}.<headless-service-name>:2181 | grep Mode); sleep 1; done; done';

zk-2 Mode: follower
zk-0 Mode: follower
zk-1 Mode: leader
zk-2 Mode: follower
```

Delete Pods and wait for the StatefulSet controller to bring them back up:

```console
$ kubectl delete po -l app=zookeeper
$ kubectl get po --watch-only
NAME          READY     STATUS    RESTARTS   AGE
zookeeper-0   0/1       Running   0          35s
zookeeper-0   1/1       Running   0         50s
zookeeper-1   0/1       Pending   0         0s
zookeeper-1   0/1       Pending   0         0s
zookeeper-1   0/1       ContainerCreating   0         0s
zookeeper-1   0/1       Running   0         19s
zookeeper-1   1/1       Running   0         40s
zookeeper-2   0/1       Pending   0         0s
zookeeper-2   0/1       Pending   0         0s
zookeeper-2   0/1       ContainerCreating   0         0s
zookeeper-2   0/1       Running   0         19s
zookeeper-2   1/1       Running   0         41s
```

Check the previously inserted key:

```console
$ kubectl exec zookeeper-1 -- /opt/zookeeper/bin/zkCli.sh get /foo
ionid = 0x354887858e80035, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
bar
```

## Scaling

ZooKeeper can not be safely scaled in versions prior to 3.5.x. This chart currently uses 3.4.10. There are manual procedures for scaling a 3.4.10 ensemble, but as noted in the [ZooKeeper 3.5.2 documentation](https://zookeeper.apache.org/doc/r3.5.2-alpha/zookeeperReconfig.html) these procedures require a rolling restart, are known to be error prone, and often result in a data loss.
