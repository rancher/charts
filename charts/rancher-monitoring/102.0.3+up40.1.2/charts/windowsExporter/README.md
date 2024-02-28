# rancher-windows-exporter

A Rancher chart based on the [prometheus-community/windows-exporter](https://github.com/prometheus-community/windows_exporter) project (previously called wmi-exporter) that sets up a DaemonSet of clients that can scrape windows-exporter metrics from Windows nodes on a Kubernetes cluster.

A [Prometheus Operator](https://github.com/coreos/prometheus-operator) ServiceMonitor CR and PrometheusRule CR are also created by this chart to collect metrics and add some recording rules to map `windows_` series with their OS-agnostic counterparts.

## Node Requirements

Since Windows does not support privileged pods, this chart expects a Named Pipe (`\\.\pipe\rancher_wins`) to exist on the Windows host that allows containers to communicate with the host. This is done by deploying a [rancher/wins](https://github.com/rancher/wins) server on the host.

The image used by the chart, [windows_exporter-package](https://github.com/rancher/windows_exporter-package), is configured to create a wins client that communicates with the wins server, alongside a running copy of a particular version of [windows-exporter](https://github.com/prometheus-community/windows_exporter). Through the wins client and wins server, the windows-exporter is able to communicate directly with the Windows host to collect metrics and expose them.

If the cluster you are installing this chart on is a custom cluster that was created via RKE1 with Windows Support enabled, your nodes should already have the wins server running; this should have been added as part of [the bootstrapping process for adding the Windows node onto your RKE1 cluster](https://github.com/rancher/rancher/blob/master/package/windows/bootstrap.ps1).

## Configuration

See [rancher-monitoring](https://github.com/rancher/charts/tree/gh-pages/packages/rancher-monitoring) for an example of how this chart can be used.
