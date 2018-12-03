## Configuration

The following table lists the configurable parameters of the kubernetes-dashboard chart and their default values.

| Parameter                 | Description                                                                                                                 | Default                                                                  |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `image.repository`        | Repository for container image                                                                                              | `k8s.gcr.io/kubernetes-dashboard-amd64`                                  |
| `image.tag`               | Image tag                                                                                                                   | `v1.8.3`                                                                 |
| `image.pullPolicy`        | Image pull policy                                                                                                           | `IfNotPresent`                                                           |
| `extraArgs`               | Additional container arguments                                                                                              | `[]`                                                                     |
| `nodeSelector`            | node labels for pod assignment                                                                                              | `{}`                                                                     |
| `tolerations`             | List of node taints to tolerate (requires Kubernetes >= 1.6)                                                                | `[]`                                                                     |
| `service.externalPort`    | Dashboard external port                                                                                                     | 443                                                                      |
| `service.internalPort`    | Dashboard internal port                                                                                                     | 443                                                                      |
| `ingress.annotations`     | Specify ingress class                                                                                                       | `kubernetes.io/ingress.class: nginx` |
| `ingress.enabled`         | Enable ingress controller resource                                                                                          | `false`                                                                  |
| `ingress.path`            | Path to match against incoming requests. Must begin with a '/'                                                              | `/`                                                                  |
| `ingress.hosts`           | Dashboard Hostnames                                                                                                         | `nil`                                                                    |
| `ingress.tls`             | Ingress TLS configuration                                                                                                   | `[]`                                                                     |
| `resources`               | Pod resource requests & limits                                                                                              | `limits: {cpu: 100m, memory: 50Mi}, requests: {cpu: 100m, memory: 50Mi}` |
| `rbac.create`             | Create & use RBAC resources                                                                                                 | `true`                                                                   |
| `rbac.clusterAdminRole`   | "cluster-admin" ClusterRole will be used for dashboard ServiceAccount ([NOT RECOMMENDED](#access-control))                  | `false`                                                                  |
| `serviceAccount.create`   | Whether a new service account name that the agent will use should be created.                                               | `true`                                                                   |
| `serviceAccount.name`     | Service account to be used. If not set and serviceAccount.create is `true` a name is generated using the fullname template. |                                                                          |
