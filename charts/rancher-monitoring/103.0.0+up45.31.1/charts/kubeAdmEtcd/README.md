# rancher-pushprox

A Rancher chart based on Rancher [PushProx](https://github.com/rancher/PushProx) that sets up a Deployment of a PushProx proxy and a DaemonSet of PushProx clients on a Kubernetes cluster.

Installs [rancher-pushprox](https://github.com/rancher/charts/tree/gh-pages/packages/rancher-pushprox) to create PushProx clients that can access their host's network and register with a PushProx proxy. A [Prometheus Operator](https://github.com/coreos/prometheus-operator) ServiceMonitor CR is also included that is configured to scrape the metrics from each of the clients through the proxy.

Using an instance of this chart is suitable for the following scenarios:
- You need to scrape metrics from a port that should not be accessible outside of the host (e.g. scraping `etcd` metrics in a hardened cluster)
- You need to scrape metrics on a host that are not exposed outside of 127.0.0.1 (e.g. scraping `kube-proxy` metrics)
- You need to scrape metrics through HTTPS using certs hosted directly on `hostPath`
- You need to scrape metrics from Kubernetes components that require authorization via a service account (e.g. permissions to make request to `/metrics`)
- You need to scrape metrics without access to cacerts (i.e. enable `insecureSkipVerify`)

The clients and proxy are created based on a Rancher fork of the [prometheus-community/PushProx](https://github.com/prometheus-community/PushProx) project.

## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API.

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.
​
> **Note:**
> In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.

> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.

Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.

As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.

## Configuration

The following tables list the configurable parameters of the rancher-pushprox chart and their default values.

### General

#### Required
| Parameter | Description | Example |
| ----- | ----------- | ------ |
| `component` | The component that is being monitored | `kube-etcd`
| `metricsPort` | The port on the host that contains the metrics you want to scrape (e.g. `http://<HOST_IP>:<metricsPort>/metrics`) | `2379` |
| `namespaceOverride` | The namespace to install the chart | `""`

#### Optional
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| `serviceMonitor.enabled` | Deploys a [Prometheus Operator](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) ServiceMonitor CR that is configured to scrape metrics on the hosts that the clients are deployed on via the proxy. Also deploys a Service that points to all pods with the expected client name that exposes the `metricsPort` selected | `true` |
| `serviceMonitor.endpoints` | A list of endpoints that will be added to the ServiceMonitor based on the [Endpoint spec](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#endpoint) | `[{port: metrics}]` |
| `service.selector` | The selector that is used to populate the Service's Endpoints object. The chart will error out on rendering templating if `.Values.clients.enabled` is set alongside this field, since it is expected that this service should point to the PushProx Clients Daemonset / Deployment | `{}` |
| `clients.enabled` | Deploys a DaemonSet of clients that are each capable of scraping endpoints on the hostNetwork it is deployed on | `true` |
| `clients.port` |  The port where the client will publish PushProx client-specific metrics. If deploying multiple clients onto the same node, the clients should not have conflicting ports | `9369` |
| `clients.proxyUrl` | Overrides the default proxyUrl setting of `http://pushprox-{{ .Values.component }}-proxy.{{ . Release.Namespace }}.svc.cluster.local:{{ .Values.proxy.port }}"` with the `proxyUrl` specified | `""` |
| `clients.useLocalhost` | Sets a flag on each client deployment to redirect scrapes directed to `HOST_IP` to `127.0.0.1` | `false` |
| `clients.https.enabled` | Enables scraping metrics via HTTPS using the provided TLS certs that exist on each host | `false` |
| `clients.https.useServiceAccountCredentials` | If set to true, the client will create a service account with permissions to scrape `/metrics` endpoint of Kubernetes components. The client will use the service account token provided to make authorized scrape requests to the Kubernetes API | `false` |
| `clients.https.insecureSkipVerify` | If set to true, the client will disable SSL security checks | `false` |
| `clients.https.certDir` | A `hostPath` where TLS certs can be found. This path is mounted as a volume on an `initContainer` which copies only the necessary files over to an EmptyDir volume used by each client. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.certFile` | The path to the TLS cert file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.keyFile` | The path to the TLS key file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.caCertFile` | The path to the TLS cacert file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.seLinuxOptions` | seLinuxOptions to be passed into the container that copies certs. Should define a container with permissions to read the files in the certDir provided on the host. Required and only used if `clients.https.enabled` is set and `clients.https.certDir` is provided. | `""` |
| `clients.metrics.enabled` | Whether the client should publish PushProx client-specific metrics. | `false` |
| `clients.rbac.additionalRules` | Additional permissions to provide to the ServiceAccount bound to the client. This can be used to provide additional permissions for the client to scrape metrics from the k8s API. Only enabled if clients.https.enabled and clients.https.useServiceAccountCredentials are true | `[]` |
| `clients.deployment.enabled` | Deploys the client as a Deployment (generally used if the underlying hostNetwork Pod that is being scraped is managed by a Deployment) | `false` |
| `clients.deployment.replicas` | The number of pods the Deployment has, it should match the number of pod the hostNetwork Deployment has. Required and only used if `client.deployment.enable` is set | `0` |
| `clients.deployment.affinity` | The affinity rules that allocate the pod to the node in which the hostNetwork Deployment's pods run. Required and only used if `client.deployment.enable` is set | `{}` |
| `clients.resources` | Set resource limits and requests for the client container | `{}` |
| `clients.nodeSelector` | Select which nodes to deploy the clients on | `{}` |
| `clients.tolerations` | Specify tolerations for clients | `[]` |
| `proxy.enabled` | Deploys the proxy that each client will register with | `true` |
| `proxy.port` | The port exposed by the proxy that each client will register with to allow metrics to be scraped from the host | `8080` |
| `proxy.resources` | Set resource limits and requests for the proxy container | `{}` |
| `proxy.nodeSelector` | Select which nodes the proxy can be deployed on | `{}` |
| `proxy.tolerations` | Specify tolerations (if necessary) to allow the proxy to be deployed on the selected node | `[]` |
| `kubeVersionOverrides` | A list of Semver constraint strings (defined by https://github.com/Masterminds/semver) and values.yaml overrides. For each key in kubeVersionOverrides, this chart will check to see if the current Kubernetes cluster's version matches any of the semver constraints provided as keys on the map. On seeing a match, the default value for each values.yaml field overridden will be updated with the new value. If multiple matches are encountered (due to overlapping semver ranges), the matches will be applied in order. | `[]`

*Tip: The filepaths set in `clients.https.<cert|key|caCert>File` can include wildcard characters*. 

See [rancher-monitoring](https://github.com/rancher/charts/tree/gh-pages/packages/rancher-monitoring) for examples of how this chart can be used.