# Istio

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart bootstraps all istio [components](https://istio.io/docs/concepts/what-is-istio/overview.html) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart can install multiple istio components as subcharts:
- ingress
- ingressgateway
- egressgateway
- sidecarInjectorWebhook
- galley
- mixer
- pilot
- security(citadel)
- grafana
- prometheus
- servicegraph
- tracing(jaeger)
- kiali

To enable or disable each component, change the corresponding `enabled` flag.
