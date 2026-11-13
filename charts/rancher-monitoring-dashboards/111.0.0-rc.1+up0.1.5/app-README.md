# Rancher Monitoring Dashboards

The `Monitoring Dashboards` chart installs a dashboard-only version of `rancher-monitoring`. This means preserving all the monitoring dashboards' functionality without depending on Rancher-shipped `kube-prometheus-stack` runtime images or components. Instead, this chart presupposes that a Prometheus stack infrastructure is already in place for it to work.
