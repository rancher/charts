# Rancher Monitoring and Alerting

 This chart is based on the upstream [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) chart. The chart deploys [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) and its CRDs along with [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana), [Prometheus Adapter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-adapter) and additional charts / Kubernetes manifests to gather metrics. It allows users to monitor their Kubernetes clusters, view metrics in Grafana dashboards, and set up alerts and notifications.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/monitoring-alerting/v2.5/).

The chart installs the following components:

- [Prometheus Operator](https://github.com/coreos/prometheus-operator)  - The operator provides easy monitoring definitions for Kubernetes services, manages [Prometheus](https://prometheus.io/) and [AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) instances, and adds default scrape targets for some Kubernetes components.
- [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/) - A collection of community-curated Kubernetes manifests, Grafana Dashboards, and PrometheusRules that deploy a default end-to-end cluster monitoring configuration.
- [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana) - Grafana allows a user to create / view dashboards based on the cluster metrics collected by Prometheus.
- [node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter) / [kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) / [rancher-pushprox](https://github.com/rancher/charts/tree/dev-v2.7/packages/rancher-monitoring/rancher-pushprox/charts) - These charts monitor various Kubernetes components across different Kubernetes cluster types.
- [Prometheus Adapter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-adapter) - The adapter allows a user to expose custom metrics, resource metrics, and external metrics on the default [Prometheus](https://prometheus.io/) instance to the Kubernetes API Server.

For more information, review the Helm README of this chart.

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
​
As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.

## Upgrading from 100.0.0+up16.6.0 to 100.1.0+up19.0.3

### Noticeable changes:
Grafana:
- `sidecar.dashboards.searchNamespace`, `sidecar.datasources.searchNamespace` and `sidecar.notifiers.searchNamespace` support a list of namespaces now.

Kube-state-metrics
- the type of `collectors` is changed from Dictionary to List.
- `kubeStateMetrics.serviceMonitor.namespaceOverride` was replaced by `kube-state-metrics.namespaceOverride`.

### Known issues:
- Occasionally, the upgrade fails with errors related to the webhook `prometheusrulemutate.monitoring.coreos.com`. This is a known issue in the upstream, and the workaround is to trigger the upgrade one more time. [32416](https://github.com/rancher/rancher/issues/32416#issuecomment-828881726)
