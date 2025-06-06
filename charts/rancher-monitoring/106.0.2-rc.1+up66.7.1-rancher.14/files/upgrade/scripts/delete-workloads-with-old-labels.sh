#!/bin/bash

set -e
set -x

# node-exporter
kubectl delete daemonset -l app=prometheus-node-exporter,release=rancher-monitoring --ignore-not-found=true

# prometheus-adapter
kubectl delete deployments -l app=prometheus-adapter,release=rancher-monitoring --ignore-not-found=true

# kube-state-metrics
kubectl delete deployments -l app.kubernetes.io/instance=rancher-monitoring,app.kubernetes.io/name=kube-state-metrics --cascade=orphan --ignore-not-found=true
kubectl delete statefulsets -l app.kubernetes.io/instance=rancher-monitoring,app.kubernetes.io/name=kube-state-metrics --cascade=orphan --ignore-not-found=true
