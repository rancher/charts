## Prerequisites
- A runnable distribution of Spark 2.3 or above.
- Kubernetes 1.8+ with RBAC enabled
- You must have Kubernetes DNS configured in your cluster.

## Configuration

The following table lists the configurable parameters of the Spark chart and their default values.

| Parameter                            | Description                                | Default                                                    |
| ------------------------------------ | ------------------------------------------ | ---------------------------------------------------------- |
| `image.repository`                   | Spark image name                           | `ranchercharts/spark`                                      |
| `image.tag`                          | Spark image tag                            | `v2.3.1`                                                   |
| `image.pullPolicy`                   | Image pull policy                          | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.pullSecrets`                  | Specify image pull secrets                 | `nil`                                                      |
| `service.type`                       | Kubernetes Service type                    | `ClusterIP`                                                |
| `rbacEnabled`                        | Enable a service account and role for the init container to use in an RBAC enabled cluster   | `true`   |
| `javaOpts.instances`                 | Kubernetes Service type                    | `ClusterIP`                                                |
| `remoteJars`                         | Kubernetes Service type                    | `ClusterIP`                                                |

## How it Works

For more details of how spark 2.3.x works in the Kubernetes please find more in [here](https://spark.apache.org/docs/latest/running-on-kubernetes.html#how-it-works).
