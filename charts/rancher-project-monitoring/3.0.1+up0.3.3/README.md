# rancher-project-monitoring

This chart installs a project-scoped version of [`rancher-monitoring`](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting), a Helm chart based off of [`kube-prometheus stack`](https://github.com/prometheus-operator/kube-prometheus). It deploys a collection of Kubernetes manifests, [Grafana](http://grafana.com/) dashboards, and [Prometheus rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) combined with documentation and scripts to provide easy to operate end-to-end Kubernetes project monitoring with [Prometheus](https://prometheus.io/) using the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator). See the [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) README for details about components, dashboards, and alerts.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

## Install Chart

This chart is not intended for standalone use; it's intended to be deployed via [Prometheus Federator](https://github.com/rancher/prometheus-federator). For a Prometheus Stack intended to be deployed standalone, please use [rancher-monitoring](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/) or the upstream [`kube-prometheus-stack`](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) project.

## Dependencies

This chart is designed to be deployed alongside an existing Prometheus Operator deployment in a cluster that has already installed the Prometheus Operator CRDs. Specifically, the chart is configured and intended to be deployed alongside [`rancher-monitoring`](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/), which deploys Prometheus Operator alongside a Cluster Prometheus that `rancher-project-monitoring` is configured to federate namespace-scoped metrics from by default.

### Configuration

Since this chart installs a project-scoped version of [`rancher-monitoring`](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/), a Helm chart based off of [`kube-prometheus-stack`](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), most of the options that apply to either of those charts will apply to this chart (e.g. support for configuring persistent volumes, ingresses, etc.) and can be passed in as part of the `spec.values` of the ProjectHelmChart that deploys this chart; however, certain advanced functionality (such as Thanos support) and options that pose security risks in Project environments (e.g. ability to `ignoreNamespaceSelectors` or modify the existing namepaceSelectors of the Cluster Prometheus, ability to mount additional scrape configs, etc.) have been removed from the `values.yaml` of the chart. For more information on how to configure values and what they mean, please see the comments and options provided on the `values.yaml` packaged with this chart.

## Further Information

For more in-depth documentation of configuration options meanings, please see

- [`rancher-monitoring`](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart)