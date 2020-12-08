# externalip-webhook

## Chart Details

This chart will create a deployment of `externalip-webhook` within your Kubernetes Cluster. It's required to mitigate k8s CVE-2020-8554.

## Installing the Chart

To install the chart with the release name `rancher-externalip-webhook`:

```bash
$ helm install rancher-externalip-webhook stable/externalip-webhook --namespace cattle-externalip-system -f values.yaml
```

## Configuration

The following table lists the configurable parameters of the externalip-webhook chart and their default values.


| Parameter                            | Description                                                                                                                | Default                                            |
| ----------------------------------   | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `allowedExternalIPCidrs`             | Allowed external IP cidrs sepparated by `,`                                                                                | `""`                                               |
| `certificates.caBundle`              | If cert-manager integration is disabled, add here self signed ca.crt in base64 format                                      | `""`                                               |
| `certificates.certManager.enabled`   | Enable cert manager integration. Cert manager should be already installed at the k8s cluster                               | `true`                                               |
| `certificates.certManager.version`   | Cert manager version to use                                                                                                | `""`                                               |
| `certificates.secretName`            | If cert-manager integration is disabled, upload certs data (ca.crt, tls.crt & tls.key) as k8s secretName in the namespace  | `"webhook-server-cert"`                         |
| `global.systemDefaultRegistry`       | Pull docker images from systemDefaultRegistry                                                                              | `""`                                               |
| `image.pullPolicy`                   | Webhook server docker pull policy                                                                                          | `"IfNotPresent"`                                |
| `image.pullSecrets`                  | Webhook server docker pull secret                                                                                          | `""`                                               |
| `image.repository`                   | Webhook server docker image repository                                                                                     | `"rancher/externalip-webhook"`                           |
| `image.tag`                          | Webhook server docker image tag  Defaults to                                                                               | `".Chart.appVersion"`                           |
| `metrics.enabled`                    | Enable metrics endpoint                                                                                                    | `false`                                               |
| `metrics.port`                       | Webhook metrics pod port                                                                                                   | `8443`                                               |
| `metrics.prometheusExport`           | Enable Prometheus export. Follow [exporting-metrics-for-prometheus](https://book.kubebuilder.io/reference/metrics.html#exporting-metrics-for-prometheus) to export the webhook metrics | `false`                                               |
| `metrics.authProxy.enabled`          | Enable auth proxy for metrics endpoint                                                                                     | `false`                                               |
| `metrics.authProxy.port`             | Webhook auth proxy pod port                                                                                                | `8080`                                               |
| `metrics.authProxy.image.pullPolicy` | Webhook auth proxy docker pull policy                                                                                      | `"IfNotPresent"`                                               |
| `metrics.authProxy.image.pullSecrets`| Webhook auth proxy docker pull secrets                                                                                     | `""`                                               |
| `metrics.authProxy.image.repository` | Webhook auth proxy docker image repository                                                                                 | `"gcr.io/kubebuilder/kube-rbac-proxy"`                  |
| `metrics.authProxy.image.pullPolicy` | Webhook auth proxy docker image tag                                                                                        | `"v0.5.0"`                                               |
| `metrics.authProxy.resources.limits.cpu`      | Webhook auth proxy resource cpu limit                                                                             | `"100m"`                                               |
| `metrics.authProxy.resources.limits.memory`   | Webhook auth proxy resource memory limit                                                                          | `"30Mi"`                                               |
| `metrics.authProxy.resources.requests.cpu`    | Webhook auth proxy wesource cpu reservation                                                                       | `"100m"`                                               |
| `metrics.authProxy.resources.requests.memory` | Webhook auth proxy resource memory reservation                                                                    | `"20Mi"`                                               |
| `nodeSelector`                       | Node labels for pod assignment                                                                                             | `{}`                                               |
| `rbac.apiVersion`                    | Rbac API version to use                                                                                                    | `"v1"`                                               |
| `resources.limits.cpu`               | Resource cpu limit                                                                                                         | `"100m"`                                               |
| `resources.limits.memory`            | Resource memory limit                                                                                                      | `"30Mi"`                                               |
| `resources.requests.cpu`             | Resource cpu reservation                                                                                                   | `"100m"`                                               |
| `resources.requests.memory`          | Resource memory reservation                                                                                                | `"20Mi"`                                               |
| `service.metricsPort`                | Webhook metrics service port                                                                                               | `8443`                                               |
| `service.webhookPort`                | Webhook server service port                                                                                                | `443`                                               |
| `serviceAccountName`                 | Webhook serviceAccountName. Just used if metrics.authProxy.enabled = false                                                 | `"default"`                                               |
| `tolerations`                        | List of node taints to tolerate (requires Kubernetes >= 1.6)                                                               | `[]`                                               |
| `webhookPort`                        | Webhook server pod port                                                                                                    | `9443`                                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install rancher-externalip-webhook stable/externalip-webhook --namespace cattle-externalip-system -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)
