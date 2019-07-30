# Harness Delegate

[Harness Delegate](https://docs.harness.io/article/de9t8iiynt-harness-architecture) is a service you run in your local network or VPC to connect your artifact servers, infrastructure, collaboration, and verification providers with the Harness Manager.

## Introduction

This chart creates a [Harness Delegate](https://docs.harness.io/article/h9tkwmkrm7-delegate-installation) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart
To add Harness helm repo with name `harness`:

```console
$ helm repo add harness https://app.harness.io/storage/harness-download/harness-helm-charts/
```

The chart requires some account specific information. You can 
download the account specific `delegate-helm-values.yaml` by going to 
Harness > Setup > Installations page

To install the chart with the release name `my-release` and `delegate-helm-values.yaml`

```console
$ helm install --name my-release harness/harness-delegate -f delegate-helm-values.yaml
```
The command deploys Harness delegate on the Kubernetes cluster.


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

## Useful commands

Get pod names:

```console
kubectl get pods -n harness-delegate
```

See startup logs:

```console
kubectl logs <pod-name> -n harness-delegate -f
```
Run a shell in a pod:

```console
kubectl exec <pod-name> -n harness-delegate -it -- bash
```
