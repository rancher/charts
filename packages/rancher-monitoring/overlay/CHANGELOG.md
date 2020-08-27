# Changelog
All notable changes from the upstream Prometheus Operator chart will be added to this file.

## [Package Version 00] - 2020-07-19
### Added
- Added [Prometheus Adapter](https://github.com/helm/charts/tree/master/stable/prometheus-adapter) as a dependency to the upstream Prometheus Operator chart to allow users to expose custom metrics from the default Prometheus instance deployed by this chart
- Remove `prometheus-operator/cleanup-crds.yaml` and `prometheus-operator/crds.yaml` from the Prometheus Operator upstream chart in favor of just using the CRD directory to install the CRDs.
- Added support for `rkeControllerManager`, `rkeScheduler`, `rkeProxy`, and `rkeEtcd` PushProx exporters for monitoring k8s components within RKE clusters
- Added support for `k3sControllerManager`, `k3sScheduler`, and `k3sProxy` PushProx exporters for monitoring k8s components within k3s clusters
- Added support for `kubeAdmControllerManager`, `kubeAdmScheduler`, `kubeAdmProxy`, and `kubeAdmEtcd` PushProx exporters for monitoring k8s components within kubeAdm clusters
- Added support for `rke2ControllerManager`, `rke2Scheduler`, `rke2Proxy`, and `rke2Etcd` PushProx exporters for monitoring k8s components within rke2 clusters
- Exposed `prometheus.prometheusSpec.ignoreNamespaceSelectors` on values.yaml and set it to `true` by default. This value instructs the default Prometheus server deployed with this chart to ignore the `namespaceSelector` field within any created ServiceMonitor or PodMonitor CRs that it selects. This prevents ServiceMonitors and PodMonitors from configuring the Prometheus scrape configuration to monitor resources outside the namespace that they are deployed in; if a user needs to have one ServiceMonitor / PodMonitor monitor resources within several namespaces, they will need to either disable this default option or create one ServiceMonitor / PodMonitor CR per namespace that they would like to monitor. Relevant fields were also updated in the default README.md
- Added `grafana.sidecar.dashboards.searchNamespace` to values.yaml with a default value of `grafana-dashboards`. The namespace provided should contain all ConfigMaps with the label `grafana_dashboard` and will be searched by the Grafana Dashboards sidecar for updates. The namespace specified is also created along with this deployment. All default dashboard ConfigMaps have been relocated from the deployment namespace to the namespace specified
- Added `grafana.sidecar.datasources.searchNamespace` to values.yaml with a default value of `grafana-datasources`. The namespace provided should contain all ConfigMaps with the label `grafana_datasource` and will be searched by the Grafana Datasources sidecar for updates. The namespace specified is also created along with this deployment. All default datasource ConfigMaps have been relocated from the deployment namespace to the namespace specified
- Added `monitoring-admin`, `monitoring-edit`, and `monitoring-view` default `ClusterRoles` to allow admins to assign roles to users to interact with Prometheus Operator CRs. These can be enabled by setting `.Values.global.rbac.userRoles.create` (default: `true`). In a typical RBAC setup, you might want to assign specific users `monitoring-edit` or `monitoring-view` within a specific namespace to allow them to set up `ServiceMonitors` / `PodMonitors` that only monitor resources within that namespace. If `.Values.global.rbac.userRoles.aggregateRolesForRBAC` is enabled, these ClusterRoles will aggregate into the respective default ClusterRoles provided by Kubernetes
- Added `grafana-config-edit` and `grafana-config-view` default `ClusterRoles` to allow admins to assign roles to users to interact with Secrets or ConfigMaps utilized by Grafana. These can be enabled by setting `.Values.global.rbac.userRoles.create` (default: `true`). In a typical RBAC setup, you might want to assign the following users with these permissions:
    - User who needs to be able to persist custom Grafana dashboards from the Grafana UI but does not need to be able to interact with Prometheus CRs: `grafana-config-edit` within the `.Values.grafana.sidecar.dashboards.searchNamespace` (default `grafana-dashboards`) namespace
    - User who needs to be able to persist new Grafana datasources but does not need to be able to interact with Prometheus CRs: `.Values.grafana.sidecar.datasources.searchNamespace` (default `grafana-datasources`) namespace
- Added default resource limits for `Prometheus Operator`, `Prometheus`, `AlertManager`, `Grafana`, `kube-state-metrics`, `node-exporter`
- Added a default template `rancher_defaults.tmpl` to AlertManager that Rancher will offer to users in order to help configure the way alerts are rendered on a notifier. Also updated the default template deployed with this chart to reference that template and added an example of a Slack config using this template as a comment in the `values.yaml`.
- Added support for private registries via introducing a new field for `global.systemDefaultRegistry` that, if supplied, will automatically be prepended onto every image used by the chart.
### Modified
- Updated the chart name from `prometheus-operator` to `rancher-monitoring` and added the `io.rancher.certified: rancher` annotation to `Chart.yaml`
- Modified the default `node-exporter` port from `9100` to `9796`
- Modified the default `nameOverride` to `rancher-monitoring`. This change is necessary as the Prometheus Adapter's default URL (`http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc`) is based off of the value used here; if modified, the default Adapter URL must also be modified
- Modified the default `namespaceOverride` to `cattle-monitoring-system`. This change is necessary as the Prometheus Adapter's default URL (`http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc`) is based off of the value used here; if modified, the default Adapter URL must also be modified
- Configured some default values for `grafana.service` values and exposed them in the default README.md
- The default namespaces the following ServiceMonitors were changed from the deployment namespace to allow them to continue to monitor metrics when `prometheus.prometheusSpec.ignoreNamespaceSelectors` is enabled:
    - `core-dns`: `kube-system`
    - `api-server`: `default`
    - `kube-controller-manager`: `kube-system`
    - `kubelet`: `{{ .Values.kubelet.namespace }}`
- Disabled the following deployments by default (can be enabled if required):
    - `AlertManager`
    - `kube-controller-manager` metrics exporter
    - `kube-etcd` metrics exporter
    - `kube-scheduler` metrics exporter
    - `kube-proxy` metrics exporter
- Updated default Grafana `deploymentStrategy` to `Recreate` to prevent deployments from being stuck on upgrade if a PV is attached to Grafana
- Modified the default `<serviceMonitor|podMonitor|rule>SelectorNilUsesHelmValues` to default to `false`. As a result, we look for all CRs with any labels in all namespaces by default rather than just the ones tagged with the label `release: rancher-monitoring`.
- Modified the default images used by the `rancher-monitoring` chart to point to Rancher mirrors of the original images from upstream.
