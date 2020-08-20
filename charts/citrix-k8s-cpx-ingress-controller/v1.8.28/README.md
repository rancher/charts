# Citrix ADC CPX with Citrix Ingress Controller running as sidecar.

In a [Kubernetes](https://kubernetes.io/) or [OpenShift](https://www.openshift.com) cluster, you can deploy [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx) with Citrix ingress controller as a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/). The Citrix ADC CPX instance is used for load balancing the North-South traffic to the microservices in your cluster. And, the sidecar Citrix ingress controller configures the Citrix ADC CPX.

## TL;DR;

### For Kubernetes
   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install cpx citrix/citrix-cpx-with-ingress-controller --set license.accept=yes
   ```

### For OpenShift

   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/

   helm install cpx citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true
   ```

> **Important:**
>
> The "license.accept" is a mandatory argument and should be set to "yes" to accept the terms of the Citrix license.


## Introduction
This Helm chart deploys a Citrix ADC CPX with Citrix ingress controller as a sidecar in the [Kubernetes](https://kubernetes.io/) or in the [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh/) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version is 1.6 or later if using Kubernetes environment.
-  The [Openshift](https://www.openshift.com) version 3.11.x or later if using OpenShift platform.
-  The [Helm](https://helm.sh/) version 3.x or later. You can follow instruction given [here](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
-  You have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator), if you want to view the metrics of the Citrix ADC CPX collected by the [metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics).
- Registration of Citrix ADC CPX in ADM: You may want to register your CPX in ADM for licensing or to obtain [servicegraph](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html). For this you will have to create a Kubernetes secret using ADM credentials and provide it while install the chart. Create a Kubernetes secret for the user name and password using the following command:

  ```
  kubectl create secret generic admlogin --from-literal=username=<adm-username> --from-literal=password=<adm-password> -n citrix-system
  ```

## Installing the Chart
Add the Citrix Ingress Controller helm chart repository using command:

   ```
   helm repo add citrix https://citrix.github.io/citrix-helm-charts/
   ```

### For Kubernetes:
#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name ``` my-release```:

   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,ingressClass[0]=<ingressClassName>
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
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,ingressClass[0]=<ingressClassName>,exporter.required=true
   ```

### For OpenShift:
Add the service account named "cpx-ingress-k8s-role" to the privileged Security Context Constraints of OpenShift:

   ```
   oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:cpx-ingress-k8s-role
   ```

#### 1. Citrix ADC CPX with Citrix Ingress Controller running as side car.
To install the chart with the release name, `my-release`, use the following command:
   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller --set license.accept=yes,openshift=true
   ```

#### 2. Citrix ADC CPX with Citrix Ingress Controller and Exporter running as side car.
[Metrics exporter](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/metrics-visualizer#visualization-of-metrics) can be deployed as sidecar to the Citrix ADC CPX and collects metrics from the Citrix ADC CPX instance. You can then [visualize these metrics](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/metrics/promotheus-grafana/) using Prometheus Operator and Grafana.
> **Note:**
>
> Ensure that you have installed [Prometheus Operator](https://github.com/coreos/prometheus-operator).

Use the following command for this:
   ```
   helm install my-release citrix/citrix-k8s-ingress-controller --set license.accept=yes,openshift=true,exporter.required=true
   ```

### Installed components

The following components are installed:

-  [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx/netscaler-cpx.html)
-  [Citrix ingress controller](https://github.com/citrix/citrix-k8s-ingress-controller) (if enabled)
-  [Exporter](https://github.com/citrix/citrix-adc-metrics-exporter) (if enabled)


## CRDs configuration

CRDs gets installed/upgraded automatically when we install/upgrade  Citrix ADC CPX with Citrix ingress controller using Helm. If you do not want to install CRDs, then set the option `crds.install` to `false`. By default, CRDs too get deleted if you uninstall through Helm. This means, even the CustomResource objects created by the customer will get deleted. If you want to avoid this data loss set `crds.retainOnDelete` to `true`.

> **Note:**
> Installing again may fail due to the presence of CRDs. Make sure that you back up all CustomResource objects and clean up CRDs before re-installing Citrix ADC CPX with Citrix ingress controller.

There are a few examples of how to use these CRDs, which are placed in the folder: [Example-CRDs](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds). Refer to them and install as needed, using the following command:
```kubectl create -f <crd-example.yaml>```

### Details of the supported CRDs:

#### authpolicies CRD: 

Authentication policies are used to enforce access restrictions to resources hosted by an application or an API server.

Citrix provides a Kubernetes CustomResourceDefinitions (CRDs) called the [Auth CRD](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/auth) that you can use with the Citrix ingress controller to define authentication policies on the ingress Citrix ADC.

Example file: [auth_example.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/auth_example.yaml)
 
#### continuousdeployments CRD  for canary:

Canary release is a technique to reduce the risk of introducing a new software version in production by first rolling out the change to a small subset of users. After user validation, the application is rolled out to the larger set of users. Citrix ADC-Integrated [Canary Deployment solution](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/canary) stitches together all components of continuous delivery (CD) and makes canary deployment easier for the application developers. 

#### httproutes and listeners CRDs for contentrouting:

[Content Routing (CR)](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/contentrouting) is the execution of defined rules that determine the placement and configuration of network traffic between users and web applications, based on the content being sent. For example, a pattern in the URL or header fields of the request.

Example files: [HTTPRoute_crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/HTTPRoute_crd.yaml), [Listener_crd.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/Listener_crd.yaml)

#### ratelimits CRD:

In a Kubernetes deployment, you can [rate limit the requests](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/ratelimit) to the resources on the back end server or services using rate limiting feature provided by the ingress Citrix ADC.

Example files: [ratelimit-example1.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/ratelimit-example1.yaml), [ratelimit-example2.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/ratelimit-example2.yaml)

#### vips CRD:

Citrix provides a CustomResourceDefinitions (CRD) called [VIP](https://github.com/citrix/citrix-k8s-ingress-controller/tree/master/crd/vip) for asynchronous communication between the IPAM controller and Citrix ingress controller.

The IPAM controller is provided by Citrix for IP address management. It allocates IP address to the service from a defined IP address range. The Citrix ingress controller configures the IP address allocated to the service as virtual IP (VIP) in Citrix ADX VPX. And, the service is exposed using the IP address.

When a new service is created, the Citrix ingress controller creates a CRD object for the service with an empty IP address field. The IPAM Controller listens to addition, deletion, or modification of the CRD and updates it with an IP address to the CRD. Once the CRD object is updated, the Citrix ingress controller automatically configures Citrix ADC-specfic configuration in the tier-1 Citrix ADC VPX.

#### rewritepolicies CRD:

In kubernetes environment, to deploy specific layer 7 policies to handle scenarios such as, redirecting HTTP traffic to a specific URL, blocking a set of IP addresses to mitigate DDoS attacks, imposing HTTP to HTTPS and so on, requires you to add appropriate libraries within the microservices and manually configure the policies. Instead, you can use the [Rewrite and Responder features](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/crd/rewrite-responder-policies-deployment.yaml) provided by the Ingress Citrix ADC device to deploy these policies.

Example files: [target-url-rewrite.yaml](https://github.com/citrix/citrix-helm-charts/tree/master/example-crds/target-url-rewrite.yaml)


## Configuration
The following table lists the configurable parameters of the Citrix ADC CPX with Citrix ingress controller as side car chart and their default values.

| Parameters | Mandatory or Optional | Default value | Description |
| ---------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the Citrix ingress controller end user license agreement. |
| image | Mandatory | `quay.io/citrix/citrix-k8s-cpx-ingress:13.0-58.30` | The Citrix ADC CPX image. |
| pullPolicy | Mandatory | IfNotPresent | The Citrix ADC CPX image pull policy. |
| cic.image | Mandatory | `quay.io/citrix/citrix-k8s-ingress-controller:1.8.28` | The Citrix ingress controller image. |
| cic.pullPolicy | Mandatory | IfNotPresent | The Citrix ingress controller image pull policy. |
| cic.required | Mandatory | true | CIC to be run as sidecar with Citrix ADC CPX |
| logLevel | Optional | DEBUG | The loglevel to control the logs generated by CIC. The supported loglevels are: CRITICAL, ERROR, WARNING, INFO, DEBUG and TRACE. For more information, see [Logging](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/configure/log-levels.md).|
| defaultSSLCert | Optional | N/A | Default SSL certificate that needs to be used as a non-SNI certificate in Citrix ADC. |
| http2ServerSide | Optional | OFF | Enables HTTP2 for Citrix ADC service group configurations. |
| logProxy | Optional | N/A | Provide Elasticsearch or Kafka or Zipkin endpoint for Citrix observability exporter. |
| nsNamespace | Optional | k8s | The prefix for the resources on the Citrix ADC CPX. |
| ingressClass | Optional | N/A | If multiple ingress load balancers are used to load balance different ingress resources. You can use this parameter to specify Citrix ingress controller to configure Citrix ADC associated with specific ingress class.|
| openshift | Optional | false | Set this argument if OpenShift environment is being used. |
| nodeSelector.key | Optional | N/A | Node label key to be used for nodeSelector option for CPX-CIC deployment. |
| nodeSelector.value | Optional | N/A | Node label value to be used for nodeSelector option in CPX-CIC deployment. |

| ADMSettings.licenseServerIP | Optional | N/A | Provide the Citrix Application Delivery Management (ADM) IP address to license Citrix ADC CPX. For more information, see [Licensing](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/licensing/)|
| ADMSettings.licenseServerPort | Optional | 27000 | Citrix ADM port if non-default port is used. |
| ADMSettings.ADMIP | Optional | |  Citrix Application Delivery Management (ADM) IP address. |
| ADMSettings.ADMFingerPrint | Optional | N/A | Citrix Application Delivery Management (ADM) Finger Print. For more information, see [this](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html). |
| ADMSettings.loginSecret | Optional | N/A | The secret key to log on to the ADM. For information on how to create the secret keys, see [Prerequisites](#prerequistes). |
| ADMSettings.bandWidthLicense | Optional | False | Set to true if you want to use bandwidth based licensing for Citrix ADC CPX. |
| ADMSettings.bandWidth | Optional | N/A | Desired bandwidth capacity to be set for Citrix ADC CPX in Mbps. |
| ADMSettings.vCPULicense | Optional | N/A | Set to true if you want to use vCPU based licensing for Citrix ADC CPX. |
| ADMSettings.cpxCores | Optional | 1 | Desired number of vCPU to be set for Citrix ADC CPX. |

| exporter.required | Optional | false | Use the argument if you want to run the [Exporter for Citrix ADC Stats](https://github.com/citrix/citrix-adc-metrics-exporter) along with Citrix ingress controller to pull metrics for the Citrix ADC CPX|
| exporter.image | Optional | `quay.io/citrix/citrix-adc-metrics-exporter:1.4.5` | The Exporter for Citrix ADC Stats image. |
| exporter.pullPolicy | Optional | IfNotPresent | The Exporter for Citrix ADC Stats image pull policy. |
| exporter.ports.containerPort | Optional | 8888 | The Exporter for Citrix ADC Stats container port. |

| coeConfig.required | Mandatory | false | Set this to true if you want to configure Citrix ADC to send metrics and transaction records to COE. |
| coeConfig.distributedTracing.enable | Optional | false | Set this value to true to enable OpenTracing in Citrix ADC. |
| coeConfig.distributedTracing.samplingrate | Optional | 100 | Specifies the OpenTracing sampling rate in percentage. |
| coeConfig.endpoint.server | Optional | N/A | Set this value as the IP address or DNS address of the  analytics server. |
| coeConfig.timeseries.port | Optional | 5563 | Specify the port used to expose COE service for timeseries endpoint. |
| coeConfig.timeseries.metrics.enable | Optional | Set this value to true to enable sending metrics from Citrix ADC. |
| coeConfig.timeseries.metrics.mode | Optional | avro |  Specifies the mode of metric endpoint. |
| coeConfig.timeseries.auditlogs.enable | Optional | false | Set this value to true to export audit log data from Citrix ADC. |
| coeConfig.timeseries.events.enable | Optional | false | Set this value to true to export events from the Citrix ADC. |
| coeConfig.transactions.enable | Optional | false | Set this value to true to export transactions from Citrix ADC. |
| coeConfig.transactions.port | Optional | 5557 | Specify the port used to expose COE service for transaction endpoint. |

| crds.install | Optional | true | Unset this argument if you don't want to install CustomResourceDefinitions which are consumed by CIC. |
| crds.retainOnDelete | Optional | false | Set this argument if you want to retain CustomResourceDefinitions even after uninstalling CIC. This will avoid data-loss of Custom Resource Objects created before uninstallation. |

> **Note:**
>
> If Citrix ADM related information is not provided during installation, Citrix ADC CPX will come up with the default license.

Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
   ```
   helm install my-release citrix/citrix-cpx-with-ingress-controller -f values.yaml
   ```

> **Tip:**
>
> The [values.yaml](https://github.com/citrix/citrix-helm-charts/blob/master/citrix-cpx-with-ingress-controller/values.yaml) contains the default values of the parameters.

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:
   ```
   helm delete my-release
   ```

## Related documentation

- [Citrix ADC CPX Documentation](https://docs.citrix.com/en-us/citrix-adc-cpx/12-1/cpx-architecture-and-traffic-flow.html)
- [Citrix ingress controller Documentation](https://developer-docs.citrix.com/projects/citrix-k8s-ingress-controller/en/latest/)
- [Citrix ingress controller GitHub](https://github.com/citrix/citrix-k8s-ingress-controller)
