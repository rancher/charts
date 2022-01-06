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
