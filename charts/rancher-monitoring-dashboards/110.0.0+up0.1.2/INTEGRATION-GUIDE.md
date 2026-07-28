# Rancher Monitoring Dashboards Integration Guide

This guide provides the instructions for installing the new `monitoring-dashboards` chart and integrating it with your own Prometheus stack. The simplest way to do this is to install `kube-prometheus-stack`, but it is not the only way. For the purpose of this document, we will assume the user is using `kube-prometheus-stack`.

## Installation

For the new `monitoring-dashboards` chart to work, it is necessary to provision the underlying monitoring infrastructure first. The monitoring infrastructure will be provided by the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) chart.

### Step 1: Add `kube-prometheus-stack` helm repository

Add the [prometheus-community](https://github.com/prometheus-community/helm-charts) helm repository. This may be performed via the Rancher UI or through [helm](https://helm.sh/docs/) CLI with the following command:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Step 2: Create the `kube-prometheus-stack` values.yaml file

Before installing `kube-prometheus-stack`, there are a few values required for the integration with `monitoring-dashboards` to work, especially for embedding the dashboards. Create a `values.yaml` file with the following required values:

```yaml
grafana:
  # NOTE: Do NOT set root_url or serve_from_sub_path here
  grafana.ini:
    security:
      allow_embedding: true
    auth:
      disable_login_form: false
    auth.anonymous:
      enabled: true
      org_role: Viewer
    dashboards:
      default_home_dashboard_path: /tmp/dashboards/rancher-default-home.json
    users:
      auto_assign_org_role: Viewer

# Prometheus configuration to pick up all ServiceMonitors
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false

# No metric exporter by default
kubeEtcd:
  enabled: false
kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
kubeProxy:
  enabled: false
```

This `values.yaml` configuration file will be applied to the `kube-prometheus-stack` chart installation process in the next step.

> [!IMPORTANT]
>
> The new `monitoring-dashboards` doesn't have the following scraping metrics enabled by default: `kubeEtcd`, `kubeControllerManager`, `kubeScheduler`, and `kubeProxy`. To export those metrics, is necessary to use and configure [pushproxy](https://github.com/prometheus-community/PushProx).

### Step 3: Install `kube-prometheus-stack` chart

The `kube-prometheus-stack` chart must be installed in the `cattle-monitoring-system` namespace, which can be accomplished in the Rancher UI or through helm CLI. Don't forget to apply the `values.yaml` created in the previous step:

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace cattle-monitoring-system \
  --create-namespace \
  --debug \
  --wait \
  -f values.yaml
```

### Step 4: Install `rancher-monitoring-dashboards`

After installing the underlying monitoring infrastructure, we can proceed to the installation of the `rancher-monitoring-dashboards` chart, which is available in the Apps tab and can be installed through the Rancher UI.

## Customization and Overrides

### Monitoring Proxy Image Customization

A single nginx pod (monitoringProxy) sits in front of Grafana, Prometheus, and Alertmanager so the Kubernetes API server's service proxy (used by Rancher UI) can reach them reliably. The nginx image can be changed with the following configuration:

```yaml
monitoringProxy:
  image:
    repository: <new/image>
    tag: <version>
```

### Service Name Overrides

The default `values.yaml` assumes standard service naming (e.g., `kube-prometheus-stack-<application>`), like so:

```yaml
grafanaProxy:
  upstreamService: kube-prometheus-stack-grafana

prometheusProxy:
  upstreamService: kube-prometheus-stack-prometheus

alertmanagerProxy:
  upstreamService: kube-prometheus-stack-alertmanager
```

This creates mirror services that are deployed alongside the new chart and used by the reverse proxy that the UI needs to work. If you have changed the names during installation, then update the `upstreamService` configuration:

```yaml
grafanaProxy:
  upstreamService: <upstream_service_name>

prometheusProxy:
  upstreamService: <upstream_service_name>

alertmanagerProxy:
  upstreamService: <upstream_service_name>
```

Make sure to disable `k3sServer` if you are not using `k3s`:

```yaml
k3sServer:
  enabled: false
```

### Project Monitoring Container Image Customization

To customize container images for Prometheus, Alertmanager, or Grafana when using prometheus-federator, apply the following overrides within your `helmProjectOperator` configuration:

```yaml
helmProjectOperator:
  valuesOverride:
    prometheus:
      prometheusSpec:
        image:
          repository: <custom_repo>
          tag: <custom_tag>
    alertmanager:
      alertmanagerSpec:
        image:
          repository: <custom_repo>
          tag: <custom_tag>
    grafana:
      image:
        repository: <custom_repo>
        tag: <custom_tag>
```

## Migrating from `rancher-monitoring` to `rancher-monitoring-dashboards`

To migrate to `rancher-monitoring-dashboards` you must uninstall the `rancher-monitoring` chart, deploy your own `kube-prometheus-stack` (see [installation](#installation) guide above), and only then install `rancher-monitoring-dashboards`. To keep and/or migrate the logging data already produced, please refer to the Grafana and Prometheus documentation:

- [Grafana | Back up Grafana](https://grafana.com/docs/grafana/latest/administration/back-up-grafana/)
- [Prometheus | TSDB Admin APIs - Snapshot](https://prometheus.io/docs/prometheus/latest/querying/api/#snapshot)
- [Prometheus | Storage](https://prometheus.io/docs/prometheus/latest/storage/)
