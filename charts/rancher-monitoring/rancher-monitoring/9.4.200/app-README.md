# Rancher Monitoring

This chart is based off of the upstream [Prometheus Operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator) chart. It supports the following functionality to enable monitoring within your cluster:
- [[Prometheus Operator](https://github.com/coreos/prometheus-operator)] Provides easy monitoring definitions for Kubernetes services and the deployment and management of one or more [Prometheus / Alertmanager](https://prometheus.io/) instances and deploys default monitors / alerts onto the cluster
- [[Prometheus Operator](https://github.com/coreos/prometheus-operator)] Deploys the upstream [Grafana](https://github.com/helm/charts/tree/master/stable/grafana) chart and deploys default dashboards onto the cluster
- [[Prometheus Operator](https://github.com/coreos/prometheus-operator)] Monitors internal Kubernetes components by deploying components such as [node-exporter](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter) and [kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics)
- [[rancher-pushprox](https://github.com/rancher/charts/tree/dev-v2.5/packages/rancher-pushprox/charts)] Sets up default Deployments and DaemonSets to monitor `kube-scheduler`, `kube-controller-manager`, `kube-proxy`, and `kube-etcd` components via nodeSelectors / tolerations for certain cluster types
- [[Prometheus Adapter](https://github.com/helm/charts/tree/master/stable/prometheus-adapter)] Exposes custom metrics, resource metrics, and external metrics on the default [Prometheus](https://prometheus.io/) instance launched by [Prometheus Operator](https://github.com/coreos/prometheus-operator)

You must install the Prometheus Operator CRDs first using the `rancher-monitoring-crd` chart before installing this chart.

```bash
helm install rancher-monitoring-crd rancher/stable
```

For more information, see the README.md of this chart.
