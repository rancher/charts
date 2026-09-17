# Prometheus Federator

This chart deploys an operator that manages Project Monitoring Stacks composed of the following set of resources that are scoped to project namespaces:
- [Prometheus](https://prometheus.io/) (managed externally by [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator))
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) (managed externally by [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator))
- [Grafana](https://github.com/helm/charts/tree/master/stable/grafana) (deployed via an embedded Helm chart)
- Default PrometheusRules and Grafana dashboards based on the collection of community-curated resources from [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/)
- Default ServiceMonitors that watch the deployed Prometheus, Grafana, and Alertmanager

Since this Project Monitoring Stack deploys Prometheus Operator CRs, an existing Prometheus Operator instance must already be deployed in the cluster for Prometheus Federator to successfully be able to deploy Project Monitoring Stacks. It is recommended to use [`rancher-monitoring`](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/) for this. For more information on how the chart works or advanced configurations, please read the `README.md`.

## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API. 

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.
​
> **Note:**
> In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.
    ​
> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.
Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.
​
As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.