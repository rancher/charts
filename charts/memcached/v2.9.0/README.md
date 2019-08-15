## Configuration

The following table lists the configurable parameters of the Memcached chart and their default values.

|      Parameter             |          Description            |                         Default                         |
|----------------------------|---------------------------------|---------------------------------------------------------|
| `image`                    | The image to pull and run       | A recent official memcached tag                         |
| `imagePullPolicy`          | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `memcached.verbosity`      | Verbosity level (v, vv, or vvv) | Un-set.                                                 |
| `memcached.maxItemMemory`  | Max memory for items (in MB)    | `64`                                                    |
| `memcached.extraArgs`      | Additional memcached arguments  | `[]`                                                    |
| `metrics.enabled`          | Expose metrics in prometheus format | false                                               |
| `metrics.image`            | The image to pull and run for the metrics exporter | A recent official memcached tag      |
| `metrics.imagePullPolicy`  | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `metrics.resources`        | CPU/Memory resource requests/limits for the metrics exporter | `{}`                       |
| `extraContainers`          | Container sidecar definition(s) as string | Un-set                                        |
| `extraVolumes`             | Volume definitions to add as string | Un-set                                              |
| `kind`                     | Install as StatefulSet or Deployment | StatefulSet                                        |
| `podAnnotations`           | Map of annotations to add to the pod(s) | `{}`                                            |
| `podLabels`                | Custom Labels to be applied to statefulset | Un-set                                       |
| `nodeSelector`             | Simple pod scheduling control | `{}`                                                      |
| `tolerations`              | Allow or deny specific node taints | `{}`                                                 |
| `affinity`                 | Advanced pod scheduling control | `{}`                                                    |
| `securityContext.enabled`  | Enable security context    | `true`                                                       |
| `securityContext.fsGroup`  | Group ID for the container | `1001`                                                       |
| `securityContext.runAsUser`| User ID for the container  | `1001`                                                       |

The above parameters map to `memcached` params. For more information please refer to the [Memcached documentation](https://github.com/memcached/memcached/wiki/ConfiguringServer).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set memcached.verbosity=v \
    stable/memcached
```

The above command sets the Memcached verbosity to `v`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/memcached
```

> **Tip**: You can use the default [values.yaml](values.yaml)
