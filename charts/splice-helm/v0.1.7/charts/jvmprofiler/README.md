# jvmprofiler

This helm chart provides an implementation of the JVMProfiler.  The JVM Profiler is used to capture metrics to be used in analyzing the Java application performance.  More details on using this tool can be found here:

* https://splicemachine.atlassian.net/wiki/spaces/PD/pages/106135571/How+to+setup+and+use+JavaScope+with+Cloudera+Manager
* https://splicemachine.atlassian.net/wiki/spaces/DBAAS/pages/73433279/How+To+JVM+Profiler+aka+JavaScope

## Chart Components

This chart will do the following:

* Create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) 

## Installing the Chart

This chart would typically be installed as a part of a parent chart.  All values are specified in the parent chart values.yaml file.  The process will create an external endpoint that looks something like the following:

```
http://ac67327df8c7011e98ca50a13efebd70-2136049394.us-east-1.elb.amazonaws.com:8686/
```

## Configuration

The following table lists the configurable parameters of the Jvmprofiler chart and their default values.

| Parameter                                         | Description                                                                        | Default                                                          |
| ------------------------------------------------- | -------------------------------                                                    | ---------------------------------------------------------------- |
| `image.registry`                                  | Where the Docker file is registered at                                             | `docker.io`                                                           |
| `image.repository`                                | JVMProfiler image                                                                  | `splicemachine/splice_base`                                    |
| `image.tag`                                       | JVMProfiler image tag                                                              | `1.0.0_ERIN`                                                          |
| `image.pullPolicy`                                | Pull policy for the images                                                         | `IfNotPresent`                                           |
| `image.pullSecrets`                               | The secret to used to connect to the image.registry                                | `regcred`                                                             |                                                         |
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
| `replicatCount`                                   | Number of pod instances to create                                                  | `1`                                                                   |
| `resources.requests.memory`                       | The amount of memory that a container needs                                        | `512Mi`                                                                   |
| `resources.requests.cpu`                          | The amount of CPU that a container needs                                           | `300m`                                                                   |
| `service.type`                                    | The type of service: ClusterIP, NodePort, LoadBalancer or ExternalName             | `LoadBalancer`                                           |
| `service.port`                                    | The backend port to direct the request to                                          | `8686`                                                                |
| `service.nodePorts.http`                          | If you specify a service.type of NodePort then it is the port to allocate          | ``                                                                    |
| `service.externalTrafficPolicy`                   | Valid values are Local or Cluster.  If Cluster client ips are not propagated.      | `Cluster`                                                             |

## Deep Dive

### Image Details

The image used for this chart is based on centos:7.4.1708. The Dockerfile can be found [here](https://github.com/splicemachine/dbaas-infrastructure/blob/master/deploy/docker/splicemachine/base/Dockerfile).

### JVM Details

The Java Virtual Machine used for this chart is the jdk-8u121-linux-x64.

## Scaling

This resource is not designed to be scaled.  It is expected that only 1 instance is needed.
