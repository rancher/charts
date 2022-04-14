# Rancher Istio Installers

A Rancher created chart that packages the istioctl binary to install via a helm chart.

# Installation Requirements 

## Chart Dependencies
- rancher-kiali-server-crd chart


## Kiali

###  Dependencies
- rancher-monitoring chart or other Prometheus installation

This dependecy installs the required CRDs for installing Kiali. Since Kiali is bundled in with Istio in this chart, if you do not have these dependencies installed, your Istio installation will fail. If you do not plan on using Kiali, set `kiali.enabled=false` when installing Istio for a succesful installation.

> **Note:** The following configuration options assume you have installed the dependecies for Kiali. Please ensure you have Promtheus in your cluster before proceeding.

The `kiali.external_services.prometheus` url is set in the values.yaml:
```
http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc:{{ prometheus.service.port }}
```
The url depends on the default values for `nameOverride`, `namespaceOverride`, and `prometheus.service.port` being set in your rancher-monitoring or other monitoring instance.

The Monitoring app sets `prometheus.prometheusSpec.ignoreNamespaceSelectors=false` which means all namespaces will be scraped by Prometheus by default. This ensures you can view traffic, metrics and graphs for resources deployed in other namespaces.

To limit scraping to specific namespaces, set `prometheus.prometheusSpec.ignoreNamespaceSelectors=true` and add one of the following configurations to ensure you can continue to view traffic, metrics and graphs for your deployed resources. 

1. Add a Service Monitor or Pod Monitor in the namespace with the targets you want to scrape.
1. Add an additionalScrapeConfig to your rancher-monitoring instance to scrape all targets in all namespaces.

# Installation
```
helm install rancher-istio . --create-namespace -n istio-system
```
