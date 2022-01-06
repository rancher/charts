# Rio

[Rio](https://rio.io) is an application deployment engine for Kubernetes.

This chart will install the rio controller, which will then install the Rio system.

Note that the [Rio CLI](https://github.com/rancher/rio/releases) is the preferred installation route, see `rio install -h` for more information.

## Configuration

See values.yaml for installation options.

## Prerequisites

Rio requires Kubernetes 1.15 or newer cluster.

## Installation

Create the namespace where Rio will be installed, `rio-system` is standard but not required:

```bash
$ kubectl create namespace rio-system
$ kubectl label namespace rio-system rio.cattle.io/is-system=true
```

Install the chart:

```bash
$ helm install --namespace rio-system --name rio ./
```

Wait for the controller to come up, and then ensure a cluster domain and IP exists:

```bash
$ kubectl -n rio-system rollout status deploy/rio-controller
$ rio info
```

## Uninstallation

To completely uninstall Rio from your system:

```bash
$ rio uninstall
$ helm delete --purge rio
```
