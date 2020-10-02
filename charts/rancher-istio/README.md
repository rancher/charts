# Rancher Istio Installers

A Rancher created chart that packages the istioctl binary to install via a helm chart.

# Installation Requirements 

## Chart Dependencies
- rancher-kiali-server-crd chart
- rancher-monitoring chart or other monitoring installation

### Kiali
The `kiali.external_services.prometheus` url is set in the values.yaml:
```
http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc:{{ prometheus.service.port }}
```
The url depends on the default values for `nameOverride`, `namespaceOverride`, and `prometheus.service.port` being set in your rancher-monitoring or other monitoring instance.

The Monitoring app sets `prometheus.prometheusSpec.ignoreNamespaceSelectors=true` which means only the `istio-system` namespace will be scraped by prometheus by default. To ensure you can view traffic, metrics and graphs for resources deployed in other namespaces you will need to add additional configuration.

There are three different ways to enable prometheus to detect resources in other namespaces:

1. Add a Service Monitor or Pod Monitor in the namespace with the targets you want to scrape.
1. Set `prometheus.prometheusSpec.ignoreNamespaceSelectors=false` on your rancher-monitoring instance.
1. Add an additionalScrapeConfig to your rancher-monitoring instance to scrape all targets in all namespaces.

# Installation
```
helm install rancher-istio . --create-namespace -n istio-system
```
