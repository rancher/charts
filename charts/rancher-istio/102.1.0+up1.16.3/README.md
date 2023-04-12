# Rancher-Istio Chart

Our [Istio](https://istio.io/) installer wraps the istioctl binary commands in a handy helm chart, including an overlay file option to allow complex customization.

See the app-readme for known issues and deprecations.

## Installation Requirements

#### Chart Dependencies
- rancher-monitoring chart or other Prometheus installation

#### Install
To install the rancher-istio chart with helm, use the following command:
```
helm install rancher-istio <location/of/the/rancher-istio/chart> --create-namespace -n istio-system
```

#### Uninstall
To ensure rancher-istio uninstalls correctly, you must uninstall rancher-istio prior to uninstalling chart dependencies (see chart dependencies for list of dependencies). This is because all definitions need to be available in order to properly build the rancher-istio objects for removal.

**If you remove dependent CRD charts prior to removing rancher-istio, you may encounter the following error:**
`Error: uninstallation completed with 1 error(s): unable to build kubernetes objects for delete: unable to recognize "": no matches for kind   "MonitoringDashboard" in version "monitoring.kiali.io/v1alpha1"`

## Addons
The addons that are included with rancher-istio are:

- Kiali
- Jaeger

Each addon has additional customization and dependencies required for them to work as expected. Use the values.yaml to customize or to enable/disable each addon.
### Kiali Addon

Kiali allows you to view and manage your istio-based service mesh through an easy to use dashboard.

####  Kiali Dependencies
##### rancher-monitoring chart or other Prometheus installation

This dependecy installs the required CRDs for installing Kiali. Since Kiali is bundled in with Istio in this chart, if you do not have these dependencies installed, your Istio installation will fail. If you do not plan on using Kiali, set `kiali.enabled=false` when installing Istio for a succesful installation.

####  Prometheus Configuration for Kiali
> **Note:** The following configuration options assume you have installed the dependecies for Kiali. Please ensure you have Promtheus in your cluster before proceeding.

The Rancher Monitoring app sets `prometheus.prometheusSpec.ignoreNamespaceSelectors=false` which means all namespaces will be scraped by Prometheus by default. This ensures you can view traffic, metrics and graphs for resources deployed in other namespaces.

To limit scraping to specific namespaces, set `prometheus.prometheusSpec.ignoreNamespaceSelectors=true` and add one of the following configurations to ensure you can continue to view traffic, metrics and graphs for your deployed resources. 

1. Add a Service Monitor or Pod Monitor in the namespace with the targets you want to scrape.
1. Add an additionalScrapeConfig to your rancher-monitoring instance to scrape all targets in all namespaces.

####  Kiali External Services

The external services that can be configured in Kiali are: Prometheus, Grafana and Tracing.

##### Prometheus
The `kiali.external_services.prometheus` url is set in the values.yaml:
```
http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc:{{ prometheus.service.port }}
```
The url depends on the default values for `nameOverride`, `namespaceOverride`, and `prometheus.service.port` being set in your rancher-monitoring or other monitoring instance.

##### Grafana
The `kiali.external_services.grafana` url is set in the values.yaml:
```
http://{{ .Values.nameOverride }}-grafana.{{ .Values.namespaceOverride }}.svc:{{ grafana.service.port }}
```
The url depends on the default values for `nameOverride`, `namespaceOverride`, and `grafana.service.port` being set in your rancher-monitoring or other monitoring instance.

##### Tracing
The `kiali.external_services.tracing` url and `.Values.tracing.contextPath` is set in the rancher-istio values.yaml:
```
http://tracing.{{ .Values.namespaceOverride }}.svc:{{ .Values.service.externalPort }}/{{ .Values.tracing.contextPath }}
```
The url depends on the default values for `namespaceOverride`, and `.Values.service.externalPort` being set in your rancher-tracing or other tracing instance.

## Jaeger Addon

Jaeger allows you to trace and monitor distributed microservices.

> **Note:** This addon is using the all-in-one Jaeger installation which is not qualified for production. Use the [Jaeger Tracing](https://www.jaegertracing.io/docs/1.21/getting-started/) documentation to determine which installation you will need for your production needs.
