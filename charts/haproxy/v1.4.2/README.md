# ![HAProxy](https://github.com/haproxytech/kubernetes-ingress/raw/master/assets/images/haproxy-weblogo-210x49.png "HAProxy")

## HAProxy Kubernetes Ingress Controller

An ingress controller is a Kubernetes resource that routes traffic from outside your cluster to services within the cluster. HAProxy Kubernetes Ingress Controller uses ConfigMap to store the haproxy configuration.

Detailed documentation can be found within the [Official Documentation](https://www.haproxy.com/documentation/hapee/2-0r1/traffic-management/kubernetes-ingress-controller/).

Additional configuration details can be found in [annotation reference](https://github.com/haproxytech/kubernetes-ingress/tree/master/documentation) and in image [arguments reference](https://github.com/haproxytech/kubernetes-ingress/blob/master/documentation/controller.md).

## Introduction

This chart bootstraps an HAProxy kubernetes-ingress deployment/daemonset on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

### Prerequisites

  - Kubernetes 1.12+
  - Helm 2.9+

## Before you begin

### Setup a Kubernetes Cluster

The quickest way to setup a Kubernetes cluster is with [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/), [AWS Elastic Kubernetes Service](https://aws.amazon.com/eks/) or [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) using their respective quick-start guides.

For setting up Kubernetes on other cloud platforms or bare-metal servers refer to the Kubernetes [getting started guide](http://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Get the latest [Helm release](https://github.com/helm/helm#install).

### Add Helm chart repo

Once you have Helm installed, add the repo as follows:

```console
helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update
```

## Install the chart

To install the chart with Helm v3 as *my-release* deployment:

```console
helm install my-release haproxytech/kubernetes-ingress
```

***NOTE***: To install the chart with Helm v2 (legacy Helm) the syntax requires adding deployment name to `--name` parameter:

```console
helm install haproxytech/kubernetes-ingress \
  --name my-release
```

### Installing with unique name

To auto-generate controller and its resources names when installing, use the following:

```console
helm install haproxytech/kubernetes-ingress \
  --generate-name
```

### Installing from a private registry

To install the chart using a private registry for controller into a separate namespace *prod*.

***NOTE***: Helm v3 requires namespace to be precreated (eg. with ```kubectl create namespace prod```)

```console
helm install my-ingress haproxytech/kubernetes-ingress  \
  --namespace prod \
  --set controller.image.tag=SOMETAG \
  --set controller.imageCredentials.registry=myregistry.domain.com \
  --set controller.imageCredentials.username=MYUSERNAME \
  --set controller.imageCredentials.password=MYPASSWORD
```

### Installing as DaemonSet

Default controller mode is [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), but it is possible to use [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) as well:

```console
helm install my-ingress2 haproxytech/kubernetes-ingress \
  --set controller.kind=DaemonSet
```

### Installing in multi-ingress environment

It is also possible to set controller ingress class to be used in [multi-ingress environments](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#using-multiple-ingress-controllers):

```console
helm install my-ingress3 haproxytech/kubernetes-ingress \
  --set controller.kind=DaemonSet \
  --set controller.ingressClass=haproxy
```

***NOTE***: make sure your Ingress routes have corresponding `ingress.class: haproxy` annotation.

### Installing with service annotations

On some environments like EKS and GKE there might be a need to pass service annotations. Syntax can become a little tedious however:

```console
helm install my-ingress3 haproxytech/kubernetes-ingress \
  --set controller.kind=DaemonSet \
  --set controller.ingressClass=haproxy \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-internal"="0.0.0.0/0" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-cross-zone-load-balancing-enabled"="true"
```

***NOTE***: With helm `--set` it is needed to put quotes and escape dots in the annotation key and commas in the value string. 

### Using values from YAML file

As opposed to using many `--set` invocations, much simpler approach is to define value overrides in a separate YAML file and specify them when invoking Helm:

*mylb.yaml*:

```yaml
controller:
  kind: DaemonSet
  ingressClass: haproxy
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
      service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
```

And invoking Helm becomes (compare to the previous example):

```console
helm install my-ingress4 -f mylb.yml haproxytech/kubernetes-ingress
```

## Upgrading the chart

To upgrade the *my-release* deployment:

```console
helm upgrade my-release haproxytech/kubernetes-ingress
```

## Uninstalling the chart

To uninstall/delete the *my-release* deployment:

```console
helm delete kubernetes-ingress
```

## Debugging

It is possible to generate a set of YAML files for testing/debugging:

```console
helm install my-release haproxytech/kubernetes-ingress \
  --debug \
  --dry-run
```

## Contributing

We welcome all contributions. Please refer to [guidelines](../CONTRIBUTING.md) on how to make a contribution.
