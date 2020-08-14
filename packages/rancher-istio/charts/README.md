# Rancher Istio Installers

A Rancher created chart that packages the istioctl binary to install via a helm chart.

# Installation

### pre-requisites

This chart depends on the rancher-kiali-server-crd chart. 

It also depends on rancher-monitoring being installed with default values for nameOverride, namespaceOverride, and the prometheus.service.port.
If those values are modified on the rancher-monitoring deployment, please adjust the `kiali.external_services.prometheus` url settings:
```
http://{{ .Values.nameOverride }}-prometheus.{{ .Values.namespaceOverride }}.svc:{{ prometheus.service.port }}
```

### installation

helm install rancher-istio ./ --create-namespace -n cattle-istio-system
