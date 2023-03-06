# Rancher Monitoring and Alerting

 This chart is based on the upstream [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) chart. The chart deploys [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) and its CRDs along with [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana), [Prometheus Adapter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-adapter) and additional charts / Kubernetes manifests to gather metrics. It allows users to monitor their Kubernetes clusters, view metrics in Grafana dashboards, and set up alerts and notifications.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/).

The chart installs the following components:

- [Prometheus Operator](https://github.com/coreos/prometheus-operator)  - The operator provides easy monitoring definitions for Kubernetes services, manages [Prometheus](https://prometheus.io/) and [AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) instances, and adds default scrape targets for some Kubernetes components.
- [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/) - A collection of community-curated Kubernetes manifests, Grafana Dashboards, and PrometheusRules that deploy a default end-to-end cluster monitoring configuration.
- [Grafana](https://github.com/helm/charts/tree/master/stable/grafana) - Grafana allows a user to create / view dashboards based on the cluster metrics collected by Prometheus.
- [node-exporter](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter) / [kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics) / [rancher-pushprox](https://github.com/rancher/charts/tree/dev-v2.5/packages/rancher-pushprox/charts) - These charts monitor various Kubernetes components across different Kubernetes cluster types.
- [Prometheus Adapter](https://github.com/helm/charts/tree/master/stable/prometheus-adapter) - The adapter allows a user to expose custom metrics, resource metrics, and external metrics on the default [Prometheus](https://prometheus.io/) instance to the Kubernetes API Server.

For more information, review the Helm README of this chart.

## Upgrading from 100.1.0+up19.0.3 to 100.2.0+up40.1.2

### Noticeable changes:
Prometheus-Operator:
 - Users of Alerting Drivers who specifically use the AlertmanagerConfig CRs will need to manually update their Sachet or prom2teams configurations on upgrading the Rancher Monitoring chart due to a change introduced by upstream with respect to how receivers added via AlertmanagerConfig CRs are named. 
 
 Receivers are now delimited by `\` instead of `-` (`<namespace>-<alertManagerConfig>-<receiverName>` to `<namespace>/<alertManagerConfig>/<receiverName>`). 

To update the Receiver configurations from the Rancher UI: 
  1. Navigate to ConfigMaps under More Resources or by searching for ConfigMaps. 
  2. Find the ConfigMap for Sachet or prom2teams.
  3. Update the receiver names to use '/' as a delimiter. 
  4. Redeploy the workloads associated with Alertmanager and Sachet / prom2teams to ensure that they pick up the new configurations.  

This change was introduced to prevent AlertmanagerConfig objects from generating identical references in the final Alertmanager configuration. For example, take the following AlertmanagerConfigs: 
- AlertmanagerConfig `foo-bar` in namespace `ns` defines a Rmeceiver with name `fred`.
- AlertmanagerConfig `bar` in namespace `ns-foo` defines a Receiver with name `fred`.

Without this patch, the resulting Alertmanager configuration would have two receivers named `ns-foo-bar-fred`, which is invalid.
With this patch, the receivers within Alerting Drivers would be named `ns/foo-bar/fred` and `ns-foo/bar/fred`, because `/` is not a valid character for namespaces.
(https://github.com/prometheus-operator/prometheus-operator/commit/80a72c42f5c62012d27330b7c5203fd110d7f764)

## Upgrading from 100.0.0+up16.6.0 to 100.1.0+up19.0.3

### Noticeable changes:
Grafana:
- `sidecar.dashboards.searchNamespace`, `sidecar.datasources.searchNamespace` and `sidecar.notifiers.searchNamespace` support a list of namespaces now.

Kube-state-metrics
- the type of `collectors` is changed from Dictionary to List.
- `kubeStateMetrics.serviceMonitor.namespaceOverride` was replaced by `kube-state-metrics.namespaceOverride`.

### Known issues:
- Occasionally, the upgrade fails with errors related to the webhook `prometheusrulemutate.monitoring.coreos.com`. This is a known issue in the upstream, and the workaround is to trigger the upgrade one more time. [32416](https://github.com/rancher/rancher/issues/32416#issuecomment-828881726)

