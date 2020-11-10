# Rancher Istio

Our [Istio](https://istio.io/) installer wraps the istioctl binary commands in a handy helm chart, including an overlay file option to allow complex customization. It also includes:
* **[Kiali](https://kiali.io/)**: Used for graphing traffic flow throughout the mesh

### Dependencies

**Rancher Monitoring  or other Prometheus installation**

The Prometheus CRDs are required for installing Kiali which is enabled by default. If you do not have Prometheus installed your Istio installation will fail. If you do not plan on using Kiali, set `kiali.enabled=false` to bypass this requirement.

### Customization

**Rancher Monitoring**

The Rancher Monitoring app sets `prometheus.prometheusSpec.ignoreNamespaceSelectors=false` which means all namespaces will be scraped by Prometheus by default. This ensures you can view traffic, metrics and graphs for resources deployed in other namespaces.

To limit scraping to specific namespaces, set `prometheus.prometheusSpec.ignoreNamespaceSelectors=true` and add one of the following configurations to ensure you can continue to view traffic, metrics and graphs for your deployed resources.

1. Add a Service Monitor or Pod Monitor in the namespace with the targets you want to scrape.
1. Add an additionalScrapeConfig to your rancher-monitoring instance to scrape all targets in all namespaces.

**Custom Prometheus Installation with Kiali**

To use a custom Monitoring installation, set the `kiali.external_services.prometheus` url in the values.yaml. This url depends on the values for `nameOverride`, `namespaceOverride`, and `prometheus.service.port`:
```
http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc:{{ prometheus.service.port }}
```

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/istio/v2.5/).
