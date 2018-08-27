# Istio

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data. Istio's control plane provides an abstraction layer over the underlying cluster management platform, such as Kubernetes, Mesos, etc. 

This chart bootstraps a [Istio](https://github.com/istio/istio/tree/master/install/kubernetes/helm/istio) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. The chart has the following components,
- grafana
- ingress
- mixer
- pilot
- prometheus
- security
- servicegraph
- zipkin
