## Configuration

The following table lists the configurable parameters of the Fluentd elasticsearch chart and their default values.


| Parameter                          | Description                                | Default                                                    |
| ---------------------------------- | ------------------------------------------ | ---------------------------------------------------------- |
| `image.repository`                 | Image                                      | `guangbo/fluentd`                                          |
| `image.tag`                        | Image tag                                  | `v1.0.0`                                                   |
| `image.pullPolicy`                 | Image pull policy                          | `IfNotPresent`                                             |
| `configMaps`                       | Fluentd configmaps                         | `default conf files`                                       |
| `env`                              | List of environment variables that are added to the fluentd pods   | ``                               |
| `nodeSelector`                     | Optional daemonset nodeSelector            | `{}`                                                       |
| `resources.limits.cpu`             | CPU limit                                  | `500m`                                                     |
| `resources.limits.memory`          | Memory limit                               | `200Mi`                                                    |
| `resources.requests.cpu`           | CPU request                                | `100m`                                                     |
| `resources.requests.memory`        | Memory request                             | `200Mi`                                                    |
| `service`                          | Service definition                         | `{}`                                                       |
| `service.type`                     | Service type (ClusterIP/NodePort)          | ClusterIP                                                  |
| `service.ports`                    | List of service ports dict [{name:...}...] | Not Set                                                    |
| `service.ports[].name`             | One of service ports name                  | Not Set                                                    |
| `service.ports[].port`             | Service port                               | Not Set                                                    |
| `service.ports[].nodePort`         | NodePort port(when service.type is NodePort) | Not Set                                                  |
| `service.ports[].protocol`         | Service protocol(optional, can be TCP/UDP) | Not Set                                                    |
| `tolerations`                      | Optional statefulset tolerations           | `{}`                                                       |
| `annotations`                      | Optional statefulset annotations           | `NULL`                                                     |
| `persistence.enabled`              | Enable persistence using PVC               | `false`                                                    |
| `persistence.storageClass`         | PVC Storage Class                          | `nil` (uses alpha storage class annotation)                |
| `persistence.accessMode`           | PVC Access Mode                            | `ReadWriteOnce`                                            |
| `persistence.size`                 | PVC Storage Request                        | `10Gi`                                                     |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install --name my-release \
    stable/fluentd-aggregator
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml stable/fluentd-aggregator
```
