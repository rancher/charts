# Deploy Citrix ADC CPX as a sidecar in Istio environment using Helm charts

Citrix ADC CPX can be deployed as a sidecar proxy in an application pod in the Istio service mesh.


# Table of Contents
1. [TL; DR;](#tldr)
2. [Introduction](#introduction)
3. [Deploy Sidecar Injector for Citrix ADC CPX using Helm chart](#deploy-sidecar-injector-for-citrix-adc-cpx-using-helm-chart)
4. [Observability using Citrix Observability Exporter](#observability-using-coe)
5. [Limitations](#limitations)
6. [Clean Up](#clean-up)
7. [Configuration Parameters](#configuration-parameters)


## <a name="tldr">TL; DR;</a>

    kubectl create namespace citrix-system
    
    curl -L https://raw.githubusercontent.com/citrix/citrix-helm-charts/master/citrix-cpx-istio-sidecar-injector/create-certs-for-cpx-istio-chart.sh > create-certs-for-cpx-istio-chart.sh

    chmod +x create-certs-for-cpx-istio-chart.sh

    ./create-certs-for-cpx-istio-chart.sh --namespace citrix-system

    helm repo add citrix https://citrix.github.io/citrix-helm-charts/

    helm install citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --name cpx-sidecar-injector --set cpxProxy.EULA=YES

## <a name="introduction">Introduction</a>

Citrix ADC CPX can act as a sidecar proxy to an application container in Istio. You can inject the Citrix ADC CPX manually or automatically using the [Istio sidecar injector](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/). Automatic sidecar injection requires resources including a Kubernetes [mutating webhook admission](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) controller, and a service. Using this Helm chart, you can create resources required for automatically deploying Citrix ADC CPX as a sidecar proxy.

In Istio servicemesh, the namespace must be labelled before applying the deployment yaml for [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection). Once the namespace is labelled, sidecars (envoy or CPX) will be injected while creating pods.
- For CPX, namespace must be labelled `cpx-injection=enabled`
- For Envoy, namespace must be labelled `istio-injection=enabled`

__Note: If a namespace is labelled with both `istio-injection` and `cpx-injection`, Envoy injection takes a priority! Citrix CPX won't be injected on top of the already injected Envoy sidecar. For using Citrix ADC as sidecar, ensure that `istio-injection` label is removed from the namespace.__

For detailed information on different deployment options, see [Deployment Architecture](https://github.com/citrix/citrix-istio-adaptor/blob/master/docs/architecture.md).

### Prerequisites

The following prerequisites are required for deploying Citrix ADC as a sidecar to an application pod.

- Ensure that **Istio version 1.3.0** is installed
- Ensure that Helm is installed. Follow this [step](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_Kubernetes.md) to install the same.
- Ensure that your cluster has Kubernetes version 1.14.0 or later and the `admissionregistration.k8s.io/v1beta1` API is enabled
- Create namespace `citrix-system`
        
        kubectl create namespace citrix-system
        
You can verify the API by using the following command:

        kubectl api-versions | grep admissionregistration.k8s.io/v1beta1

The following output indicates that the API is enabled:

        admissionregistration.k8s.io/v1beta1


## <a name="deploy-sidecar-injector-for-citrix-adc-cpx-using-helm-chart">Deploy Sidecar Injector for Citrix ADC CPX using Helm chart</a>

**Before you Begin**

You must generate a TLS certificate suitable for the Istio webhook service using the `create-certs-for-cpx-istio-chart.sh` script.
This script is available in the [citrix-cpx-istio-sidecar-injector](../citrix-cpx-istio-sidecar-injector) folder.

To create a suitable certificate for the Istio webhook service, perform the following steps:


1. Change the permissions of the `create-certs-for-cpx-istio-chart.sh` script to executable mode.
        
        chmod +x citrix-cpx-istio-sidecar-injector/create-certs-for-cpx-istio-chart.sh
2. Execute the script to generate the certificate. Specify the namespace where you want to deploy sidecar injector for Citrix ADC CPX.
        
        . citrix-cpx-istio-sidecar-injector/create-certs-for-cpx-istio-chart.sh --namespace citrix-system

 To deploy resources for automatic installation of Citrix ADC CPX as a sidecar in Istio, perform the following step. In this example, release name is specified as `cpx-sidecar-injector`  and namespace is used as `citrix-system`.


    helm repo add citrix https://citrix.github.io/citrix-helm-charts/

    helm citrix/install citrix-cpx-istio-sidecar-injector --name cpx-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES

This step installs a mutating webhook and a service resource to application pods in the namespace labeled as `cpx-injection=enabled`.

*"Note:" The `cpx-injection=enabled` label is mandatory for injecting sidecars.*

An example to deploy application along with Citrix ADC CPX sidecar is provided [here](https://github.com/citrix/citrix-helm-charts/tree/master/examples/citrix-adc-in-istio).


# <a name="observability-using-coe"> Observability using Citrix Observability Exporter </a>

### Pre-requisites

1. Citrix Observability Exporter (COE) should be deployed in the cluster.

2. Citrix ADC CPX should be running with versions 13.0-48+ or 12.1-56+.

Citrix ADC CPXes serving East West traffic send its metrics and transaction data to COE which has a support for Prometheus and Zipkin. 

Metrics data can be visualized in Prometheus dashboard. 

Zipkin enables users to analyze tracing for East-West service to service communication.

*Note*: Istio should be [installed](https://istio.io/docs/tasks/observability/distributed-tracing/zipkin/#before-you-begin) with Zipkin as tracing endpoint.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install citrix/citrix-cpx-istio-sidecar-injector --name cpx-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --istioAdaptor.coeURL=<coe-service-name>.<namespace>
```

For example, if COE is deployed as `coe` in `citrix-system` namespace, then below helm command will deploy sidecar injector webhook which will be deploying Citrix ADC CPX sidecar proxies in application pods, and these sidecar proxies will be configured to establish communication channels with COE.

```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install citrix/citrix-cpx-istio-sidecar-injector --name cpx-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --istioAdaptor.coeURL=coe.citrix-system
```

*Important*: Apply below mentioned annotations on COE deployment so that Prometheus can scrape data from COE.
```
        prometheus.io/scrape: "true"
        prometheus.io/port: "5563" # Prometheus port
```

## <a name="limitations">Limitations</a>

Citrix ADC CPX occupies certain ports for internal usage. This makes application service running on one of these restricted ports incompatible with the Citrix ADC CPX.
The list of ports is mentioned below. Citrix is working on delisting some of the major ports from the given list, and same shall be available in future releases.

#### Restricted Ports

| Sr No |Port Number|
|-------|-----------|
| 1 | 80 |
| 2 | 3010 |
| 3 | 5555 |
| 4 | 8080 |

## <a name="clean-up">Clean Up</a>

To delete the resources created for automatic injection with the release name  `cpx-sidecar-injector`, perform the following step.

    helm delete --purge cpx-sidecar-injector

## <a name="configuration-parameters">Configuration parameters</a>

The following table lists the configurable parameters and their default values in the Helm chart.


| Parameter                      | Description                   | Default                   |
|--------------------------------|-------------------------------|---------------------------|
| `istioAdaptor.image`                    | Image of the Citrix Istio Adaptor container                    |  quay.io/citrix/citrix-istio-adaptor   |
| `istioAdaptor.tag`             | Tag of the Istio-adaptor image       | 1.2.0                |
| `istioAdaptor.imagePullPolicy`   | Image pull policy for Istio-adaptor | IfNotPresent        |
| `istioAdaptor.secureConnect`     | If this value is set to true, Istio-adaptor establishes secure gRPC channel with Istio Pilot   | TRUE                       |
| `istioAdaptor.ADMIP`     | Provide the Citrix Application Delivery Management (ADM) IP address | NIL                       |
| `istioAdaptor.ADMFingerPrint`          | Citrix Applicatin Delivery Management (ADM) FingerPrint. For more information, see [this](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html)  | NIL           
| `istioAdaptor.coeURL`          | Name of [Citrix Observability Exporter](https://github.com/citrix/citrix-observability-exporter) Service in the form of _servicename.namespace_  | NIL            | Optional|
| `istioPilot.name`                 | Name of the Istio Pilot service     | istio-pilot                                                           |
| `istioPilot.namespace`     | Namespace where Istio Pilot is running       | istio-system                                                          |
| `istioPilot.secureGrpcPort`       | Secure GRPC port where Istio Pilot is listening (Default setting)                                                                  | 15011                                                                 |
| `istioPilot.insecureGrpcPort`      | Insecure GRPC port where Istio Pilot is listening                                                                                  | 15010                                                                 |
| `istioPilot.proxyType`      | Type of Citrix ADC associated with the Istio-adaptor. Possible values are: sidecar and router.                                                                              |   sidecar|
| `istioPilot.netscalerUrl`   |    URL or IP address of the Citrix ADC which will be configured by Istio-adaptor.                                                            | http://127.0.0.1 |
| `istioPilot.SAN`                 | Subject alternative name for Istio Pilot which is the Secure Production Identity Framework For Everyone (SPIFFE) ID of Istio Pilot.                                   | spiffe://cluster.local/ns/istio-system/sa/istio-pilot-service-account |
| `cpxProxy.image`          | Citrix ADC CPX image used as sidecar proxy                                                                                                    | quay.io/citrix/citrix-k8s-cpx-ingress |  
| `cpxProxy.tag`             | Version of the Citrix ADC CPX                                                                                   |13.0-47.22                            |
| `cpxProxy.imagePullPolicy`           | Image pull policy for Citrix ADC                                                                                  | IfNotPresent                                                               |
| `cpxProxy.EULA`              |  End User License Agreement(EULA) terms and conditions. If yes, then user agrees to EULA terms and conditions.                                                     | Yes                                                               |
| `cpxProxy.cpxSidecarMode`            | Environment variable for Citrix ADC CPX. It indicates that Citrix ADC CPX is running as sidecar mode or not.                                                                                               | NO                                                                    |
| `cpxProxy.licenseServerPort`   | Citrix ADM port if a non-default port is used                                                                                      | 27000                                                          |
| `sidecarWebHook.webhookImage`   | Mutating webhook associated with the sidecar injector. It invokes a service `cpx-sidecar-injector` to inject sidecar proxies in the application pod.                                                                                      | gcr.io/istio-release/sidecar_injector|
| `sidecarWebHook.webhookImageVersion`   | Image version                                                                         |1.0.0|
| `sidecarWebHook.imagePullPolicy`   | Image pull policy                                                                          |IfNotPresent|
| `webhook.injectionLabelName` |  Label of namespace where automatic Citrix ADC CPX sidecar injection is required. | cpx-injection |

**Note:** You can use the `values.yaml` file packaged in the chart. This file contains the default configuration values for the chart.
