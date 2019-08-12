# Harness Delegate

The [Harness Delegate](https://docs.harness.io/article/de9t8iiynt-harness-architecture) is a service that you run in your local network or VPC to connect Harness Manager with your artifact servers, infrastructure, collaboration providers, and verification providers.

## Introduction

This chart creates a [Harness Delegate](https://docs.harness.io/article/h9tkwmkrm7-delegate-installation) deployment on a [Kubernetes](http://kubernetes.io) cluster, using the [Helm](https://helm.sh) package manager.


## Installing the Chart
To add a Harness Helm repo named `harness`:

```console
$ helm repo add harness https://app.harness.io/storage/harness-download/harness-helm-charts/
```

The chart requires some account-specific information. You can download the account-specific `delegate-helm-values.yaml` file by going to Harness Manager > Setup > Harness Delegates > Download Delegate > Helm Values YAML.

To install the chart using release name `my-release` and the `delegate-helm-values.yaml`

```console
$ helm install --name my-release harness/harness-delegate -f delegate-helm-values.yaml
```
Above command deploys Harness Delegate on the Kubernetes cluster.


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm del --purge my-release
```

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
