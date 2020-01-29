# Citrix ADC CPX with Citrix Ingress Controller running as sidecar.

In a [Kubernetes](https://kubernetes.io/) or [OpenShift](https://www.openshift.com) cluster, you can deploy [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx) with Citrix ingress controller as a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/). The Citrix ADC CPX instance is used for load balancing the North-South traffic to the microservices in your cluster. And, the sidecar Citrix ingress controller configures the Citrix ADC CPX.

## TL;DR;

### For Kubernetes
```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install citrix/citrix-k8s-cpx-ingress-controller --set license.accept=yes
```

### For OpenShift

```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install citrix/citrix-k8s-cpx-ingress-controller --set license.accept=yes,openshift=true
```
> **Important:**
>
> The "license.accept" is a mandatory argument and should be set to "yes" to accept the terms of the Citrix license.


## Introduction
This Helm chart deploys a Citrix ADC CPX with Citrix ingress controller as a sidecar in the [Kubernetes](https://kubernetes.io/) or in the [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh/) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version is 1.6 or later if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 3.11.x or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version is 2.8.x or later. You can follow instruction given [here](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_Kubernetes.md) to install Helm in Kubernetes environment and [here](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_OpenShift.md) for OpenShift platform.
-  You have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator), if you want to view the metrics of the Citrix ADC CPX collected by the [metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics).

## Installing the Chart
Add the Citrix Ingress Controller helm chart repository using command:

```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/
```

### For Kubernetes:
#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name ``` my-release```:

```
   helm install citrix/citrix-k8s-cpx-ingress-controller --name my-release --set license.accept=yes,ingressClass[0]=<ingressClassName>
```
> **Note:**
>
> By default the chart installs the recommended [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) roles and role bindings.

The command deploys Citrix ADC CPX with Citrix ingress controller as a sidecar on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the mandatory and optional parameters that you can configure during installation.

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
```
   helm install citrix/citrix-k8s-cpx-ingress-controller --name my-release --set license.accept=yes,ingressClass[0]=<ingressClassName>,exporter.required=true
```

### For OpenShift:
If Citrix ADC CPX with Citrix ingress controller running as side car needs to be deployed in the OpenShift platform please install Helm and Tiller using instruction given [here](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_OpenShift.md). It will make sure Helm and Tiller have the proper permission that is needed to install Citrix ingress controller on OpenShift.

Add the service account named "cpx-ingress-k8s-role" to the privileged Security Context Constraints of OpenShift:

```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:cpx-ingress-k8s-role
```

#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name, `my-release`, use the following command:
```
   helm install citrix/citrix-k8s-cpx-ingress-controller --name my-release --set license.accept=yes,openshift=true
```

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
```
   helm install citrix/citrix-k8s-ingress-controller --name my-release --set license.accept=yes,openshift=true,exporter.required=true
```

### Installed components

The following components are installed:

-  [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx/netscaler-cpx.html)
-  [Citrix ingress controller](https://github.com/citrix/citrix-k8s-ingress-controller) (if enabled)
-  [Exporter](https://github.com/citrix/citrix-adc-metrics-exporter) (if enabled)

## Configuration
The following table lists the configurable parameters of the Citrix ADC CPX with Citrix ingress controller as side car chart and their default values.

| Parameters | Mandatory or Optional | Default value | Description |
| ---------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the Citrix ingress controller end user license agreement. |
| cpx.image | Mandatory | `quay.io/citrix/citrix-k8s-cpx-ingress:13.0-47.102` | The Citrix ADC CPX image. |
| cpx.pullPolicy | Mandatory | Always | The Citrix ADC CPX image pull policy. |
| lsIP | Optional | N/A | Provide the Citrix Application Delivery Management (ADM) IP address to license Citrix ADC CPX. For more information, see [Licensing](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/licensing/)|
| lsPort | Optional | 27000 | Citrix ADM port if non-default port is used. |
| platform | Optional | N/A | Platform license. The platform is **CP1000**. |
| cic.image | Mandatory | `quay.io/citrix/citrix-k8s-ingress-controller:1.6.1` | The Citrix ingress controller image. |
| cic.pullPolicy | Mandatory | Always | The Citrix ingress controller image pull policy. |
| cic.required | Mandatory | true | CIC to be run as sidecar with Citrix ADC CPX |
| defaultSSLCert | Optional | N/A | Default SSL certificate that needs to be used as a non-SNI certificate in Citrix ADC. |
| nsNamespace | Optional | k8s | The prefix for the resources on the Citrix ADC CPX. |
| exporter.required | Optional | false | Use the argument if you want to run the [Exporter for Citrix ADC Stats](https://github.com/citrix/citrix-adc-metrics-exporter) along with Citrix ingress controller to pull metrics for the Citrix ADC CPX|
| exporter.image | Optional | `quay.io/citrix/citrix-adc-metrics-exporter:1.4.0` | The Exporter for Citrix ADC Stats image. |
| exporter.pullPolicy | Optional | Always | The Exporter for Citrix ADC Stats image pull policy. |
| exporter.ports.containerPort | Optional | 8888 | The Exporter for Citrix ADC Stats container port. |
| ingressClass | Optional | N/A | If multiple ingress load balancers are used to load balance different ingress resources. You can use this parameter to specify Citrix ingress controller to configure Citrix ADC associated with specific ingress class.|
| openshift | Optional | false | Set this argument if OpenShift environment is being used. |

> **Note:**
>
> If Citrix ADM related information is not provided during installation, Citrix ADC CPX will come up with the default license.

Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
```
    helm install citrix/citrix-k8s-cpx-ingress-controller --name my-release --set license.accept=yes,ingressClass[0]=<ingressClassName> -f values.yaml
```

> **Tip:**
>
> The [values.yaml](https://github.com/citrix/citrix-helm-charts/blob/master/citrix-k8s-cpx-ingress-controller/values.yaml) contains the default values of the parameters.

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:
```
   helm delete --purge my-release
```

## Related documentation

-  [Citrix ADC CPX Documentation](https://docs.citrix.com/en-us/citrix-adc-cpx/12-1/cpx-architecture-and-traffic-flow.html)
-  [Citrix ingress controller Documentation](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/)
