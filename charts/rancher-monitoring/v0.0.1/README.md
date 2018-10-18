# rancher-monitoring

Installs [prometheus-operator](https://github.com/coreos/prometheus-operator) to create/configure/manage Prometheus clusters atop Kubernetes.

> **Tip**: Only use for Rancher Monitoring!!!

## Introduction

This chart bootstraps a [prometheus-operator](https://github.com/coreos/prometheus-operator) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

### Security

Alertmanager, Node exporter, Kube-state exporter, Grafana and Prometheus in same [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) will use the same [ServiceAccount](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) as Prometheus, which named like `prometheus-{{ .Release.Name }}`. Operator uses another one.

## Prerequisites
  - Rancher 2.1+
