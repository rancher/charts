# Datadog

[Datadog](https://www.datadoghq.com/) is a hosted infrastructure monitoring platform.

This chart adds the Datadog Agent to all nodes in your cluster via a DaemonSet. The chart optionally also deploys the [kube-state-metrics](https://github.com/kubernetes/charts/tree/master/stable/kube-state-metrics) chart.

Note: Before deploying this chart, ensure that kubelet API access is properly configured in your cluster (see README).
