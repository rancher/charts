# Deploy Citrix ADC as an Ingress Gateway in Istio environment using Helm charts

Citrix Application Delivery Controller (ADC) can be deployed as an Istio Ingress Gateway to control the ingress traffic to Istio service mesh.

# Table of Contents
1. [TL; DR;](#tldr)
2. [Introduction](#introduction)
3. [Deploy Citrix ADC VPX or MPX as an Ingress Gateway](#deploy-citrix-adc-vpx-or-mpx-as-an-ingress-gateway)
4. [Deploy Citrix ADC CPX as an Ingress Gateway](#deploy-citrix-adc-cpx-as-an-ingress-gateway)
5. [Using Existing Certificates to deploy Citrix ADC as an Ingress Gateway](#using-existing-certificates-to-deploy-citrix-adc-as-an-ingress-gateway)
6. [Segregating traffic with multiple Ingress Gateways](#segregating-traffic-with-multiple-ingress-gateways)
7. [Visualizing statistics of Citrix ADC Ingress Gateway with Metrics Exporter](#visualizing-statistics-of-citrix-adc-ingress-gateway-with-metrics-exporter)
8. [Exposing services running on non-HTTP ports](#exposing-services-running-on-non-http-ports)
9. [Citrix ADC as Ingress Gateway: a sample deployment](#citrix-adc-as-ingress-gateway-a-sample-deployment)
10. [Uninstalling the Helm chart](#uninstalling-the-helm-chart)
11. [Configuration Parameters](#configuration-parameters)


## <a name="tldr">TL; DR;</a>

### To deploy Citrix ADC VPX or MPX as an Ingress Gateway:

       kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

       helm repo add citrix https://citrix.github.io/citrix-helm-charts/

       helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name citrix-adc-istio-ingress-gateway --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address> 

### To deploy Citrix ADC CPX as an Ingress Gateway:

       helm repo add citrix https://citrix.github.io/citrix-helm-charts/

       helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name citrix-adc-istio-ingress-gateway --set ingressGateway.EULA=YES --set citrixCPX=true


## <a name="introduction">Introduction</a>

This chart deploys Citrix ADC VPX, MPX, or CPX as an Ingress Gateway in the Istio service mesh using the Helm package manager. For detailed information on different deployment options, see [Deployment Architecture](https://github.com/citrix/citrix-istio-adaptor/blob/master/docs/architecture.md).

### Prerequisites

The following prerequisites are required for deploying Citrix ADC as an Ingress Gateway in Istio service mesh:

- Ensure that **Istio version 1.3.0** is installed
- Ensure that Helm is installed. Follow this [step](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_Kubernetes.md) to install the same.
- Ensure that your cluster has Kubernetes version 1.14.0 or later and the `admissionregistration.k8s.io/v1beta1` API is enabled
- **For deploying Citrix ADC VPX or MPX as an Ingress gateway:**

  Create a Kubernetes secret for the Citrix ADC user name and password using the following command:
  
        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

You can verify the API by using the following command:

        kubectl api-versions | grep admissionregistration.k8s.io/v1beta1

The following output indicates that the API is enabled:

        admissionregistration.k8s.io/v1beta1

- **Important Note:** For deploying Citrix ADC VPX or MPX as ingress gateway, you should establish the connectivity between Citrix ADC VPX or MPX and cluster nodes. This connectivity can be established by configuring routes on Citrix ADC as mentioned [here](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/staticrouting.md) or by deploying [Citrix Node Controller](https://github.com/citrix/citrix-k8s-node-controller).
  

## <a name="deploy-citrix-adc-vpx-or-mpx-as-an-ingress-gateway">Deploy Citrix ADC VPX or MPX as an Ingress Gateway</a>

 To deploy Citrix ADC VPX or MPX as an Ingress Gateway in the Istio service mesh, do the following step. In this example, release name is specified as `citrix-adc-istio-ingress-gateway` and namespace as `citrix-system`.

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system
        
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name citrix-adc-istio-ingress-gateway --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address> 

## <a name="deploy-citrix-adc-cpx-as-an-ingress-gateway">Deploy Citrix ADC CPX as an Ingress Gateway</a>

 To deploy Citrix ADC CPX as an Ingress Gateway, do the following step. In this example, release name is specified as `my-release` and namespace is used as `citrix-system`.

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --name my-release --namespace citrix-system --set ingressGateway.EULA=YES --set citrixCPX=true


## <a name="using-existing-certificates-to-deploy-citrix-adc-as-an-ingress-gateway">Using Existing Certificates to deploy Citrix ADC as an Ingress Gateway</a>

You may want to use the existing certificate and key for authenticating access to an application using Citrix ADC Ingress Gateway. In that case, you can create a Kubernetes secret from the existing certificate and key. You can mount the Kubernetes secret as data volumes in Citrix ADC Ingress Gateway.

To create a Kubernetes secret using an existing key named `test_key.pem` and a certificate named `test.pem`, use the following command:

        kubectl create -n citrix-system secret tls citrix-ingressgateway-certs --key test_key.pem --cert test.pem 

Note: Ensure that Kubernetes secret is created in the same namespace where Citrix ADC Ingress Gateway is deployed.

To deploy Citrix ADC VPX or MPX with secret volume, do the following step:

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name my-release --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address>  --set ingressGateway.secretVolumes[0].name=test-ingressgateway-certs --set ingressGateway.secretVolumes[0].secretName=test-ingressgateway-certs --set ingressGateway.secretVolumes[0].mountPath=/etc/istio/test-ingressgateway-certs 

To deploy Citrix ADC CPX with secret volume, do the following step:

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name my-release --set ingressGateway.EULA=YES --set citrixCPX=true --set ingressGateway.secretVolumes[0].name=test-ingressgateway-certs --set ingressGateway.secretVolumes[0].secretName=test-ingressgateway-certs --set ingressGateway.secretVolumes[0].mountPath=/etc/istio/test-ingressgateway-certs 

## <a name="segregating-traffic-with-multiple-ingress-gateways">Segregating traffic with multiple Ingress Gateways</a>

You can deploy multiple Citrix ADC Ingress Gateway devices and segregate traffic to various deployments in the Istio service mesh. This can be achieved with *custom labels*. By default, Citrix ADC Ingress Gateway service comes up with the `app: citrix-ingressgateway` label. This label is used as a selector while deploying the Ingress Gateway or virtual service resources. If you want to deploy Ingress Gateway with the custom label, you can do it using the `ingressGateway.label` option in the Helm chart. 

To deploy Citrix ADC CPX Ingress Gateway with the label `my_custom_ingressgateway`, do the following step:

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system
        
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --name my-release --namespace citrix-system --set ingressGateway.EULA=YES --set citrixCPX=true  --set ingressGateway.lightWeightCPX=NO --set ingressGateway.label=my_custom_ingressgateway

To deploy Citrix ADC VPX or MPX as an Ingress Gateway with the label `my_custom_ingressgateway`, do the following step:

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --name my-release --namespace citrix-system --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address> --set ingressGateway.label=my_custom_ingressgateway

## <a name="visualizing-statistics-of-citrix-adc-ingress-gateway-with-metrics-exporter">Visualizing statistics of Citrix ADC Ingress Gateway with Metrics Exporter</a>

By default, [Citrix ADC Metrics Exporter](https://github.com/citrix/citrix-adc-metrics-exporter) is also deployed along with Citrix ADC Ingress Gateway. Citrix ADC Metrics Exporter fetches statistical data from Citrix ADC and exports it to Prometheus running in Istio service mesh. When you add Prometheus as a data source in Grafana, you can visualize this statistical data in the Grafana dashboard.

Metrics Exporter requires the IP address of Citrix ADC CPX or VPX Ingress Gateway. It is retrieved from the value specified for `istioAdaptor.netscalerUrl`.

When Citrix ADC CPX is deployed as Ingress Gateway, Metrics Exporter runs along with Citrix CPX Ingress Gateway in the same pod and specifying IP address is optional.

To deploy Citrix ADC as Ingress Gateway without Metrics Exporter, set the value of `metricExporter.required` as false.


        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system
    
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name citrix-adc-istio-ingress-gateway --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address> --set metricExporter.required=false

"Note:" To remotely access telemetry addons such as Prometheus and Grafana, see [Remotely Accessing Telemetry Addons](https://istio.io/docs/tasks/telemetry/gateways/).

## <a name="exposing-services-running-on-non-http-ports">Exposing services running on non-HTTP ports</a>

By default, services running on HTTP ports (80 & 443) are exposed through Citrix ADC Ingress Gateway. Similarly, you can expose services that are deployed on non-HTTP ports through the Citrix ADC Ingress Gateway device.

To deploy Citrix ADC MPX or VPX, and expose a service running on a TCP port, do the following step.

In this example, a service running on TCP port 5000 is exposed using port 10000 on Citrix ADC.

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name my-release --set ingressGateway.EULA=YES --set istioAdaptor.netscalerUrl=https://<nsip>[:port] --set istioAdaptor.vserverIP=<IPv4 Address> --set ingressGateway.tcpPort[0].name=tcp1 --set ingressGateway.tcpPort[0].port=10000 --set ingressGateway.tcpPort[0].targetPort=5000 

 To deploy Citrix ADC CPX and expose a service running on a TCP port, do the following step.
 In this example, port 10000 on the Citrix ADC CPX instance is exposed using TCP port 30000 (node port configuration) on the host machine.

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --name my-release --set ingressGateway.EULA=YES --set citrixCPX=true --set ingressGateway.tcpPort[0].name=tcp1 --set ingressGateway.tcpPort[0].nodePort=30000 --set ingressGateway.tcpPort[0].port=10000 --set ingressGateway.tcpPort[0].targetPort=5000



## <a name="citrix-adc-as-ingress-gateway-a-sample-deployment">Citrix ADC as Ingress Gateway: a sample deployment</a>

A sample deployment of Citrix ADC as an Ingress gateway for the Bookinfo application is provided [here](https://github.com/citrix/citrix-helm-charts/tree/master/examples/citrix-adc-in-istio).

## <a name="uninstalling-the-helm-chart">Uninstalling the Helm chart</a>

To uninstall or delete a chart with release name as `my-release`, do the following step.

        helm delete --purge my-release

The command removes all the Kubernetes components associated with the chart and deletes the release.

## <a name="configuration-parameters">Configuration parameters</a>

The following table lists the configurable parameters in the Helm chart and their default values.




| Parameter                      | Description                   | Default                   | Optional/Mandatory                  |
|--------------------------------|-------------------------------|---------------------------|---------------------------|
| `citrixCPX`                    | Citrix ADC CPX                    | FALSE                  | Mandatory for Citrix ADC CPX |
| `istioAdaptor.image`            | Image of the Citrix Istio-adaptor container |quay.io/citrix/citrix-istio-adaptor| Mandatory|
| `istioAdaptor.tag`               | Tag of the Istio adaptor image | 1.2.0                 | Mandatory|
| `istioAdaptor.imagePullPolicy`   | Image pull policy for Istio-adaptor | IfNotPresent       | Optional|
| `istioAdaptor.vserverIP`       | Virtual server IP address on Citrix ADC (Mandatory if citrixCPX=false) | null | Mandatory for Citrix ADC MPX or VPX|
| `istioAdaptor.netscalerUrl`       | URL or IP address of the Citrix ADC which Istio-adaptor configures (Mandatory if citrixCPX=false)| null   |Mandatory for Citrix ADC MPX or VPX|
| `istioAdaptor.secureConnect`     | If this value is set to true, Istio-adaptor establishes secure gRPC channel with Istio Pilot   | TRUE                       | Optional|
| `istioAdaptor.netProfile `          | Network profile name used by [CNC](https://github.com/citrix/citrix-k8s-node-controller) to configure Citrix ADC VPX or MPX which is deployed as Ingress Gateway  | null            | Optional|
| `istioAdaptor.coeURL`          | Name of [Citrix Observability Exporter](https://github.com/citrix/citrix-observability-exporter) Service in the form of "<servicename>.<namespace>"  | null            | Optional|
| `istioAdaptor.ADMIP `          | Citrix Application Delivery Management (ADM) IP address  | NIL            | Mandatory for Citrix ADC CPX |
| `istioAdaptor.ADMFingerPrint `          | Citrix Application Delivery Management (ADM) Finger Print. For more information, see [this](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html)  | NIL            | Optional|
| `ingressGateway.image`             | Image of Citrix ADC CPX designated to run as Ingress Gateway                                                                       |quay.io/citrix/citrix-k8s-cpx-ingress|   Mandatory for Citrix ADC CPX                                                              |
| `ingressGateway.tag`              | Version of Citrix ADC CPX                                                                                                          | 13.0-47.22                  | Mandatory for Citrix ADC CPX |
| `ingressGateway.imagePullPolicy`   | Image pull policy                                                                                                                  | IfNotPresent                                                          | Optional|
| `ingressGateway.EULA`             | End User License Agreement(EULA) terms and conditions. If yes, then user agrees to EULA terms and conditions.                                     | NO                                                                    | Mandatory for Citrix ADC CPX 
| `ingressGateway.mgmtHttpPort`      | Management port of the Citrix ADC CPX                                                                                              | 9080                                                                  | Optional|
| `ingressGateway.mgmtHttpsPort`    | Secure management port of Citrix ADC CPX                                                                                           | 9443                                                                  | Optional|
| `ingressGateway.httpNodePort`      | Port on host machine which is used to expose HTTP port (80) of Citrix ADC CPX                                                       | 30180                                                                 |Optional|
| `ingressGateway.httpsNodePort`     | Port on host machine which is used to expose HTTPS port (443) of Citrix ADC CPX                                                     | 31443                                                                 |Optional|
| `ingressGateway.secretVolume`      | A map of user defined volumes to be mounted using Kubernetes secrets                                                               | null                                                                  |Optional|
| `ingressGateway.licenseServerPort` | Citrix ADM port if a non-default port is used                                                                                        | 27000                                                                 | Optional|
| `ingressGateway.label` | Custom label for the Ingress Gateway service                                                                                       | citrix-ingressgateway                                                                 |Optional|
| `ingressGateway.tcpPort` | For exposing multiple TCP ingress                                                                                      | NIL                                                                 |Optional|
| `istioPilot.name`                 | Name of the Istio Pilot service                                                                                                        | istio-pilot                                                           |Optional|
| `istioPilot.namespace`     | Namespace where Istio Pilot is running                                                                                        | istio-system                                                          |Optional|
| `istioPilot.secureGrpcPort`       | Secure GRPC port where Istio Pilot is listening (default setting)                                                                  | 15011                                                                 |Optional|
| `istioPilot.insecureGrpcPort`      | Insecure GRPC port where Istio Pilot is listening                                                                                  | 15010                                                                 |Optional|
| `istioPilot.SAN`                 | Subject alternative name for Istio Pilot which is the secure production identity framework for everyone (SPIFFE) ID of Istio Pilot                                                        | spiffe://cluster.local/ns/istio-system/sa/istio-pilot-service-account |Optional|
| `metricExporter.required`          | Metrics exporter for Citrix ADC                                                                                                    | TRUE                                                                  |Optional|
| `metricExporter.image`             | Image of the Citrix ADC Metrics Exporter                                                                                   | quay.io/citrix/citrix-adc-metrics-exporter                             |Optional|
| `metricExporter.version`           | Version of the Citrix ADC Metrics Exporter image                                                                                   | 1.4.0                                                            |Optional|
| `metricExporter.port`              | Port over which Citrix ADC Metrics Exporter collects metrics of Citrix ADC.                                                      | 8888                                                                  |Optional|
| `metricExporter.secure`            | Enables collecting metrics over TLS                                                                                                | YES                                                                    |Optional|
| `metricExporter.logLevel`          | Level of logging in Citrix ADC Metrics Exporter. Possible values are: DEBUG, INFO, WARNING, ERROR, CRITICAL                                       | ERROR                                                                 |Optional|
| `metricExporter.imagePullPolicy`   | Image pull policy for Citrix ADC Metrics Exporter                                                                                       | IfNotPresent                                                          |Optional|

