# Deploy Citrix ADC as an Ingress Gateway in Istio environment using Helm charts

Citrix Application Delivery Controller (ADC) can be deployed as an Istio Ingress Gateway to control the ingress traffic to Istio service mesh.

# Table of Contents
1. [TL; DR;](#tldr)
2. [Introduction](#introduction)
3. [Deploy Citrix ADC VPX or MPX as an Ingress Gateway](#deploy-citrix-adc-vpx-or-mpx-as-an-ingress-gateway)
4. [Deploy Citrix ADC CPX as an Ingress Gateway](#deploy-citrix-adc-cpx-as-an-ingress-gateway)
5. [Using Existing Certificates to deploy Citrix ADC as an Ingress Gateway](#using-existing-certificates-to-deploy-citrix-adc-as-an-ingress-gateway)
6. [Deploy Citrix ADC as an Ingress Gateway in multi cluster Istio Service mesh](#deploy-citrix-adc-as-a-multicluster-ingress-gateway)
7. [Segregating traffic with multiple Ingress Gateways](#segregating-traffic-with-multiple-ingress-gateways)
8. [Visualizing statistics of Citrix ADC Ingress Gateway with Metrics Exporter](#visualizing-statistics-of-citrix-adc-ingress-gateway-with-metrics-exporter)
9. [Exposing services running on non-HTTP ports](#exposing-services-running-on-non-http-ports)
10. [Generate Certificate for Ingress Gateway](#generate-certificate-for-ingress-gateway)
11. [Citrix ADC CPX License Provisioning](#citrix-adc-cpx-license-provisioning)
12. [Service Graph configuration](#configuration-for-servicegraph)
13. [Citrix ADC as Ingress Gateway: a sample deployment](#citrix-adc-as-ingress-gateway-a-sample-deployment)
14. [Uninstalling the Helm chart](#uninstalling-the-helm-chart)
15. [Citrix ADC VPX/MPX Certificate Verification](#citrix-adc-vpx-or-mpx-certificate-verification)
16. [Configuration Parameters](#configuration-parameters)


## <a name="tldr">TL; DR;</a>

### To deploy Citrix ADC VPX or MPX as an Ingress Gateway:

       kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

       helm repo add citrix https://citrix.github.io/citrix-helm-charts/

       helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set ingressGateway.netscalerUrl=https://<nsip>[:port] --set ingressGateway.vserverIP=<IPv4 Address> --set secretName=nslogin

### To deploy Citrix ADC CPX as an Ingress Gateway:

       helm repo add citrix https://citrix.github.io/citrix-helm-charts/

       helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set citrixCPX=true


## <a name="introduction">Introduction</a>

This chart deploys Citrix ADC VPX, MPX, or CPX as an Ingress Gateway in the Istio service mesh using the Helm package manager. For detailed information on different deployment options, see [Deployment Architecture](https://github.com/citrix/citrix-istio-adaptor/blob/master/docs/istio-integration/architecture.md).

### Prerequisites

The following prerequisites are required for deploying Citrix ADC as an Ingress Gateway in Istio service mesh:

- Ensure that **Istio version 1.8 onwards** is installed
- Ensure that Helm with version 3.x is installed. Follow this [step](https://github.com/citrix/citrix-helm-charts/blob/master/Helm_Installation_version_3.md) to install the same.
- Ensure that your cluster Kubernetes version should be in range 1.16 to 1.21 and the `admissionregistration.k8s.io/v1`, `admissionregistration.k8s.io/v1beta1` API is enabled

  You can verify the API by using the following command:

        kubectl api-versions | grep admissionregistration.k8s.io/v1

  The following output indicates that the API is enabled:

        admissionregistration.k8s.io/v1
        admissionregistration.k8s.io/v1beta1

- **For deploying Citrix ADC VPX or MPX as an Ingress gateway:**

  Create a Kubernetes secret for the Citrix ADC user name and password using the following command:
  
        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system


- **Create system user account for xDS-adaptor in Citrix ADC:**

  The Citrix ADC appliance needs to have system user account (non-default) with certain privileges so that `xDS-adaptor` can configure the Citrix ADC VPX or MPX appliance. Follow the instructions to create the system user account on Citrix ADC.

    Create a Kubernetes secret for the user name and password using the following command:

    ```
       kubectl create secret generic nslogin --from-literal=username='cxa' --from-literal=password='mypassword'
    ```

  The `xDS-adaptor` configures the Citrix ADC using a system user account of the Citrix ADC. The system user account should have certain privileges so that the xDS-adaptor has permissions configure the following on the Citrix ADC:

  -  Add, Delete, or View Content Switching (CS) virtual server
  -  Configure CS policies and actions
  -  Configure Load Balancing (LB) virtual server
  -  Configure Service groups
  -  Cofigure SSl certkeys
  -  Configure routes
  -  Configure user monitors
  -  Add system file (for uploading SSL certkeys from Kubernetes)
  -  Configure Virtual IP address (VIP)
  -  Check the status of the Citrix ADC appliance
  -  Add, Delete or view authentication virtual server, policy, authaction
  -  Add, Delete or view Policy
  -  Add, Delete or view Responder policy, action, param
  -  Add, Delete or view Rewrite policy, action, param
  -  Add, Delete or view analytics profile
  -  Add, Delete or view DNS name server
  -  Add, Delete or view network netprofile
  -  Add, Delete or view Traffic Management Commands(sessionaction, session policy, sessionparameter)


> **Note:**
>
> The system user account would have privileges based on the command policy that you define.

 To create the system user account, do the following:

 1.  Log on to the Citrix ADC appliance. Perform the following:
     1.  Use an SSH client, such as PuTTy, to open an SSH connection to the Citrix ADC appliance.

     2.  Log on to the appliance by using the administrator credentials.

 2.  Create the system user account using the following command:

     ```
        add system user <username> <password>
     ```

     For example:

     ```
        add system user cxa mypassword
     ```

 3.  Create a policy to provide required permissions to the system user account. Use the following command:

     ```
        add cmdpolicy cxa-policy ALLOW "((^\S+\s+cs\s+\S+)|(^\S+\s+lb\s+\S+)|(^\S+\s+service\s+\S+)|(^\S+\s+servicegroup\s+\S+)|(^stat\s+system)|(^show\s+ha)|(^\S+\s+ssl\s+certKey)|(^\S+\s+ssl)|(^\S+\s+route)|(^\S+\s+monitor)|(^show\s+ns\s+ip)|(^\S+\s+system\s+file)|)|(^\S+\s+aaa\s+\S+)|(^\S+\s+aaa\s+\S+\s+.*)|(^\S+\s+authentication\s+\S+)|(^\S+\s+authentication\s+\S+\s+.*)|(^\S+\s+policy\s+\S+)|(^\S+\s+policy\s+\S+\s+.*)|(^\S+\s+rewrite\s+\S+)|(^\S+\s+rewrite\s+\S+\s+.*)|(^\S+\s+analytics\s+\S+)|(^\S+\s+analytics\s+\S+\s+.*)|(^\S+\s+dns\s+\S+)|(^\S+\s+dns\s+\S+\s+.*)|(^\S+\s+netProfile)|(^\S+\s+netProfile\s+.*)|(^\S+\s+tm\s+\S+)|(^\S+\s+tm\s+\S+\s+.*)"
     ```

 4.  Bind the policy to the system user account using the following command:

     ```
        bind system user cxa cxa-policy 0
     ```

- **Registration of Citrix ADC CPX in ADM**

Create a secret for ADM username and password

        kubectl create secret generic admlogin --from-literal=username=<adm-username> --from-literal=password=<adm-password> -n citrix-system

- **Important Note:** For deploying Citrix ADC VPX or MPX as ingress gateway, you should establish the connectivity between Citrix ADC VPX or MPX and cluster nodes. This connectivity can be established by configuring routes on Citrix ADC as mentioned [here](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/staticrouting.md) or by deploying [Citrix Node Controller](https://github.com/citrix/citrix-k8s-node-controller).
  

## <a name="deploy-citrix-adc-vpx-or-mpx-as-an-ingress-gateway">Deploy Citrix ADC VPX or MPX as an Ingress Gateway</a>

 To deploy Citrix ADC VPX or MPX as an Ingress Gateway in the Istio service mesh, do the following step. In this example, release name is specified as `citrix-adc-istio-ingress-gateway` and namespace as `citrix-system`.

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system
        
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address> --set secretName=nslogin

## <a name="deploy-citrix-adc-cpx-as-an-ingress-gateway">Deploy Citrix ADC CPX as an Ingress Gateway</a>

 To deploy Citrix ADC CPX as an Ingress Gateway, do the following step. In this example, release name is specified as `my-release` and namespace is used as `citrix-system`.

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,citrixCPX=true


## <a name="deploy-citrix-adc-as-a-multicluster-ingress-gateway">Deploy Citrix ADC as an Ingress Gateway in multi cluster Istio Service mesh</a>

To deploy **Citrix ADC VPX/MPX as an Ingress Gateway** in multi cluster Istio Service mesh, carry out below steps.
```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address> --set ingressGateway.multiClusterIngress=true 
```

To deploy **Citrix ADC CPX as an Ingress Gateway** in multi cluster Istio Service mesh, carry out below steps.
```
helm repo add citrix https://citrix.github.io/citrix-helm-charts/

helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,citrixCPX=true --set ingressGateway.multiClusterIngress=true 

```

By default, port 15443 of the Citrix ADC will be used to handle all the inter-cluster traffic coming to services deployed in local cluster. These services are exposed using `*.global` domain.
To modify the default 15443 port and "global" domain, use _ingressGateway.multiClusterListenerPort_ and _ingressGateway.multiClusterSvcDomain_ options of helm chart.

For example, to use port 25443 and _mydomain_ as the service domain to expose local cluster deployed services to services in remote clusters.

```

helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address> --set ingressGateway.multiClusterIngress=true --set ingressGateway.multiClusterListenerPort=25443 --set ingressGateway.multiClusterSvcDomain=mydomain

```

Follow [this](https://github.com/citrix/citrix-helm-charts/tree/master/examples/citrix-adc-ingress-in-multicluster-istio/README.md) as a sample example to deploy Citrix ADC as Ingress gateway in multi-cluster Istio service mesh.

## <a name="using-existing-certificates-to-deploy-citrix-adc-as-an-ingress-gateway">Using Existing Certificates to deploy Citrix ADC as an Ingress Gateway</a>

You may want to use the existing certificate and key for authenticating access to an application using Citrix ADC Ingress Gateway. In that case, you can create a Kubernetes secret from the existing certificate and key. You can mount the Kubernetes secret as data volumes in Citrix ADC Ingress Gateway.

To create a Kubernetes secret using an existing key named `test_key.pem` and a certificate named `test.pem`, use the following command:

        kubectl create -n citrix-system secret tls citrix-ingressgateway-certs --key test_key.pem --cert test.pem 

Note: Ensure that Kubernetes secret is created in the same namespace where Citrix ADC Ingress Gateway is deployed.

To deploy Citrix ADC VPX or MPX with secret volume, do the following step:

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,secretName=nslogin,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address>,ingressGateway.secretVolumes[0].name=test-ingressgateway-certs,ingressGateway.secretVolumes[0].secretName=test-ingressgateway-certs,ingressGateway.secretVolumes[0].mountPath=/etc/istio/test-ingressgateway-certs

To deploy Citrix ADC CPX with secret volume, do the following step:

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,citrixCPX=true,ingressGateway.secretVolumes[0].name=test-ingressgateway-certs,ingressGateway.secretVolumes[0].secretName=test-ingressgateway-certs,ingressGateway.secretVolumes[0].mountPath=/etc/istio/test-ingressgateway-certs

## <a name="segregating-traffic-with-multiple-ingress-gateways">Segregating traffic with multiple Ingress Gateways</a>

You can deploy multiple Citrix ADC Ingress Gateway devices and segregate traffic to various deployments in the Istio service mesh. This can be achieved with *custom labels*. By default, Citrix ADC Ingress Gateway service comes up with the `app: citrix-ingressgateway` label. This label is used as a selector while deploying the Ingress Gateway or virtual service resources. If you want to deploy Ingress Gateway with the custom label, you can do it using the `ingressGateway.label` option in the Helm chart. 

To deploy Citrix ADC CPX Ingress Gateway with the label `my_custom_ingressgateway`, do the following step:
        
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,citrixCPX=true,ingressGateway.lightWeightCPX=NO,ingressGateway.label=my_custom_ingressgateway

To deploy Citrix ADC VPX or MPX as an Ingress Gateway with the label `my_custom_ingressgateway`, do the following step:

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,secretName=nslogin,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address>,ingressGateway.label=my_custom_ingressgateway

## <a name="visualizing-statistics-of-citrix-adc-ingress-gateway-with-metrics-exporter">Visualizing statistics of Citrix ADC Ingress Gateway with Metrics Exporter</a>

By default, [Citrix ADC Metrics Exporter](https://github.com/citrix/citrix-adc-metrics-exporter) is also deployed along with Citrix ADC Ingress Gateway. Citrix ADC Metrics Exporter fetches statistical data from Citrix ADC and exports it to Prometheus running in Istio service mesh. When you add Prometheus as a data source in Grafana, you can visualize this statistical data in the Grafana dashboard.

Metrics Exporter requires the IP address of Citrix ADC CPX or VPX Ingress Gateway. It is retrieved from the value specified for `ingressGateway.netscalerUrl`.

When Citrix ADC CPX is deployed as Ingress Gateway, Metrics Exporter runs along with Citrix CPX Ingress Gateway in the same pod and specifying IP address is optional.

To deploy Citrix ADC as Ingress Gateway without Metrics Exporter, set the value of `metricExporter.required` as false.


        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system
    
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,secretName=nslogin,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address>,metricExporter.required=false

"Note:" To remotely access telemetry addons such as Prometheus and Grafana, see [Remotely Accessing Telemetry Addons](https://istio.io/docs/tasks/telemetry/gateways/).

## <a name="exposing-services-running-on-non-http-ports">Exposing services running on non-HTTP ports</a>

By default, services running on HTTP ports (80 & 443) are exposed through Citrix ADC Ingress Gateway. Similarly, you can expose services that are deployed on non-HTTP ports through the Citrix ADC Ingress Gateway device.

To deploy Citrix ADC MPX or VPX, and expose a service running on a TCP port, do the following step.

In this example, a service running on TCP port 5000 is exposed using port 10000 on Citrix ADC.

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,secretName=nslogin,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address>,ingressGateway.tcpPort[0].name=tcp1,ingressGateway.tcpPort[0].port=10000,ingressGateway.tcpPort[0].targetPort=5000

 To deploy Citrix ADC CPX and expose a service running on a TCP port, do the following step.
 In this example, port 10000 on the Citrix ADC CPX instance is exposed using TCP port 30000 (node port configuration) on the host machine.

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install my-release citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,citrixCPX=true,ingressGateway.tcpPort[0].name=tcp1,ingressGateway.tcpPort[0].nodePort=30000,ingressGateway.tcpPort[0].port=10000,ingressGateway.tcpPort[0].targetPort=5000

## <a name="generate-certificate-for-ingress-gateway">Generate Certificate for Ingress Gateway </a>

Citrix Ingress gateway needs TLS certificate-key pair for establishing secure communication channel with backend applications. Earlier these certificates were issued by Istio Citadel and bundled in Kubernetes secret. Certificate was loaded in the application pod by doing volume mount of secret. Now `xDS-Adaptor` can generate its own certificate and get it signed by the Istio Citadel (Istiod). This eliminates the need of secret and associated [risks](https://kubernetes.io/docs/concepts/configuration/secret/#risks). 

xDS-Adaptor needs to be provided with details Certificate Authority (CA) for successful signing of Certificate Signing Request (CSR). By default, CA is `istiod.istio-system.svc` which accepts CSRs on port 15012. 
To skip this process, don't provide any value (empty string) to `certProvider.caAddr`.
```
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set citrixCPX=true --set certProvider.caAddr=""
```
### <a name="using-third-party-service-account-tokens">Configure Third Party Service Account Tokens</a>

In order to generate certificate for application workload, xDS-Adaptor needs to send valid service account token along with Certificate Signing Request (CSR) to the Istio control plane (Citadel CA). Istio control plane authenticates the xDS-Adaptor using this JWT. 
Kubernetes supports two forms of these tokens:

* Third party tokens, which have a scoped audience and expiration.
* First party tokens, which have no expiration and are mounted into all pods.
 
 If Kubernetes cluster is installed with third party tokens, then the same information needs to be provided for automatic sidecar injection by passing `--set certProvider.jwtPolicy="third-party-jwt"`. By default, it is `first-party-jwt`.

```
        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install cpx-sidecar-injector citrix/citrix-cpx-istio-sidecar-injector --namespace citrix-system --set cpxProxy.EULA=YES --set certProvider.caAddr="istiod.istio-system.svc" --set certProvider.jwtPolicy="third-party-jwt"

```

To determine if your cluster supports third party tokens, look for the TokenRequest API using below command. If there is no output, then it is `first-party-jwt`. In case of `third-party-jwt`, output will be like below.

```
# kubectl get --raw /api/v1 | jq '.resources[] | select(.name | index("serviceaccounts/token"))'

{
    "name": "serviceaccounts/token",
    "singularName": "",
    "namespaced": true,
    "group": "authentication.k8s.io",
    "version": "v1",
    "kind": "TokenRequest",
    "verbs": [
        "create"
    ]
}

```

## <a name="citrix-adc-cpx-license-provisioning">**Citrix ADC CPX License Provisioning**</a>
By default, CPX runs with 20 Mbps bandwidth called as [CPX Express](https://www.citrix.com/en-in/products/citrix-adc/cpx-express.html) however for better performance and production deployment customer needs licensed CPX instances. [Citrix ADM](https://www.citrix.com/en-in/products/citrix-application-delivery-management/) is used to check out licenses for Citrix ADC CPX.

**Bandwidth based licensing**
For provisioning licensing on Citrix ADC CPX, it is mandatory to provide License Server information to CPX. This can be done by setting **ADMSettings.licenseServerIP** as License Server IP. In addition to this, **ADMSettings.bandWidthLicense** needs to be set true and desired bandwidth capacity in Mbps should be set **ADMSettings.bandWidth**.
For example, to set 2Gbps as bandwidth capacity, below command can be used.

	helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set ADMSettings.licenseServerIP=<Licenseserver_IP>,ADMSettings.bandWidthLicense=True --set ADMSettings.bandWidth=2000 --set citrixCPX=true

## <a name="configuration-for-servicegraph">**Service Graph configuration**</a>
   Citrix ADM Service graph is an observability tool that allows user to analyse service to service communication. The service graph is generated by ADM post collection of transactional data from registered Citrix ADC instances. More details about it can be found [here](https://docs.citrix.com/en-us/citrix-application-delivery-management-service/application-analytics-and-management/service-graph.html).
   Citrix ADC needs to be provided with ADM details for registration and data export. This section lists the steps needed to deploy Citrix ADC and register it with ADM.

**Deploy Citrix ADC CPX as ingress gateway**
   1. Create secret using Citrix ADM Agent credentials, which will be used by Citrix ADC as CPX to communicate with Citrix ADM Agent:

	kubectl create secret generic admlogin --from-literal=username=<adm-agent-username> --from-literal=password=<adm-agent-password>

   2. Deploy Citrix ADC CPX as ingress gateway using helm command with `ADM` details:

	helm install citrix-adc-istio-ingress-gateway citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set citrixCPX=true --set ADMSettings.ADMIP=<ADM-Agent-IP>


> **Note:**
> If container agent is being used here for Citrix ADM, specify `PodIP` of container agent in the `ADMSettings.ADMIP` parameter.

**Deploy Citrix ADC VPX/MPX as ingress gateway**

   Deploy Citrix ADC VPX/MPX as ingress gateway using helm command and set analytics settings on Citrix ADC VPX/MPX for sending transaction metrics to Citrix ADM
	
	helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES --set ingressGateway.netscalerUrl=https://<nsip>[:port] --set ingressGateway.vserverIP=<IPv4 Address> --set secretName=nslogin

   Add the following configurations in Citrix ADC VPX/MPX  

      	en ns mode ulfd
      
      	en ns feature appflow
      
      	add appflow collector logproxy_lstreamd -IPAddress <ADM-AGENT-IP/POD-IP> -port 5557 -Transport logstream

      	set appflow param -templateRefresh 3600 -httpUrl ENABLED -httpCookie ENABLED -httpReferer ENABLED -httpMethod ENABLED -httpHost ENABLED -httpUserAgent ENABLED -httpContentType ENABLED -httpAuthorization ENABLED -httpVia ENABLED -httpXForwardedFor ENABLED -httpLocation ENABLED -httpSetCookie ENABLED -httpSetCookie2 ENABLED -httpDomain ENABLED -httpQueryWithUrl ENABLED  metrics ENABLED -events ENABLED -auditlogs ENABLED
      
      	add appflow action logproxy_lstreamd -collectors logproxy_lstreamd
      
      	add appflow policy logproxy_policy true logproxy_lstreamd
      
      	bind appflow global logproxy_policy 10 END -type REQ_DEFAULT 
      
      	bind appflow global logproxy_policy 10 END -type OTHERTCP_REQ_DEFAULT

	
> **Note:**
> If container agent is being used here for Citrix ADM, specify `PodIP` of container agent.


## <a name="citrix-adc-as-ingress-gateway-a-sample-deployment">Citrix ADC as Ingress Gateway: a sample deployment</a>

A sample deployment of Citrix ADC as an Ingress gateway for the Bookinfo application is provided [here](https://github.com/citrix/citrix-helm-charts/tree/master/examples/citrix-adc-in-istio).

## <a name="uninstalling-the-helm-chart">Uninstalling the Helm chart</a>

To uninstall or delete a chart with release name as `my-release`, do the following step.

        helm delete my-release

The command removes all the Kubernetes components associated with the chart and deletes the release.

## <a name="citrix-adc-vpx-or-mpx-certificate-verification">Citrix ADC VPX/MPX Certificate Verification</a>

Create a Kubernetes secret holding the CA certificate of Citrix ADC VPX/MPX with the filename `root-cert.pem`.

        kubectl create secret generic citrix-adc-cert --from-file=./root-cert.pem

Note: Ensure that Kubernetes secret is created in the same namespace where Citrix ADC Ingress Gateway is deployed.

To deploy Citrix ADC VPX or MPX with Citrix ADC certificate verification, do the following step:

        kubectl create secret generic nslogin --from-literal=username=<citrix-adc-user> --from-literal=password=<citrix-adc-password> -n citrix-system

        helm repo add citrix https://citrix.github.io/citrix-helm-charts/

        helm install citrix-adc-istio-ingress-gateway citrix/citrix-adc-istio-ingress-gateway --namespace citrix-system --set ingressGateway.EULA=YES,secretName=nslogin,ingressGateway.netscalerUrl=https://<nsip>[:port],ingressGateway.vserverIP=<IPv4 Address>,ingressGateway.adcServerName=<ADC Cert Server Name>

## <a name="configuration-parameters">Configuration parameters</a>

The following table lists the configurable parameters in the Helm chart and their default values.


| Parameter                      | Description                   | Default                   | Optional/Mandatory                  |
|--------------------------------|-------------------------------|---------------------------|---------------------------|
| `citrixCPX`                    | Citrix ADC CPX                    | FALSE                  | Mandatory for Citrix ADC CPX |
| `xDSAdaptor.image`            | Image of the Citrix xDS adaptor container |quay.io/citrix/citrix-xds-adaptor:0.9.8 | Mandatory|
| `xDSAdaptor.imagePullPolicy`   | Image pull policy for xDS adaptor | IfNotPresent       | Optional|
| `xDSAdaptor.secureConnect`     | If this value is set to true, xDS-adaptor establishes secure gRPC channel with Istio Pilot   | TRUE                       | Optional|
| `xDSAdaptor.logLevel`   | Log level to be set for xDS-adaptor log messages. Possible values: TRACE (most verbose), DEBUG, INFO, WARN, ERROR (least verbose) | DEBUG       | Optional|
| `xDSAdaptor.jsonLog`   | Set this argument to true if log messages are required in JSON format | false       | Optional|
| `coe.coeURL`          | Name of [Citrix Observability Exporter](https://github.com/citrix/citrix-observability-exporter) Service in the form of "<servicename>.<namespace>"  | null            | Optional|
| `coe.coeTracing`          | Use COE to send appflow transactions to Zipkin endpoint. If it is set to true, ADM servicegraph (if configured) can be impacted.  | false           | Optional|
| `ADMSettings.ADMIP `          | Citrix Application Delivery Management (ADM) IP address  | null            | Mandatory for Citrix ADC CPX |
| `ADMSettings.licenseServerIP `          | Citrix License Server IP address  | null            | Optional |
| `ADMSettings.licenseServerPort` | Citrix ADM port if a non-default port is used                                                                                        | 27000                                                                 | Optional|
| `ADMSettings.bandWidth`          | Desired bandwidth capacity to be set for Citrix ADC CPX in Mbps  | null            | Optional |
| `ADMSettings.bandWidthLicense`          | To specify bandwidth based licensing  | false            | Optional |
| `ingressGateway.netscalerUrl`       | URL or IP address of the Citrix ADC which Istio-adaptor configures (Mandatory if citrixCPX=false)| null   |Mandatory for Citrix ADC MPX or VPX|
| `ingressGateway.vserverIP`       | Virtual server IP address on Citrix ADC (Mandatory if citrixCPX=false) | null | Mandatory for Citrix ADC MPX or VPX|
| `ingressGateway.adcServerName `          | Citrix ADC ServerName used in the Citrix ADC certificate  | null            | Optional |
| `ingressGateway.image`             | Image of Citrix ADC CPX designated to run as Ingress Gateway                                                                       |quay.io/citrix/citrix-k8s-cpx-ingress:13.0-79.64 |   Mandatory for Citrix ADC CPX    |
| `ingressGateway.imagePullPolicy`   | Image pull policy                                                                                                                  | IfNotPresent                                                          | Optional|
| `ingressGateway.EULA`             | End User License Agreement(EULA) terms and conditions. If yes, then user agrees to EULA terms and conditions.                                     | NO                                                                    | Mandatory for Citrix ADC CPX 
| `ingressGateway.mgmtHttpPort`      | Management port of the Citrix ADC CPX                                                                                              | 9080                                                                  | Optional|
| `ingressGateway.mgmtHttpsPort`    | Secure management port of Citrix ADC CPX                                                                                           | 9443                                                                  | Optional|
| `ingressGateway.httpNodePort`      | Port on host machine which is used to expose HTTP port (80) of Citrix ADC CPX                                                       | 30180                                                                 |Optional|
| `ingressGateway.httpsNodePort`     | Port on host machine which is used to expose HTTPS port (443) of Citrix ADC CPX                                                     | 31443                                                                 |Optional|
| `ingressGateway.nodePortRequired`     | Set this argument if servicetype to be NodePort of Citrix ADC CPX                                                     | false                                                                 |Optional|
| `ingressGateway.secretVolume`      | A map of user defined volumes to be mounted using Kubernetes secrets                                                               | null                                                                  |Optional|
| `ingressGateway.label` | Custom label for the Ingress Gateway service                                                                                       | citrix-ingressgateway                                                                 |Optional|
| `ingressGateway.netProfile `          | Network profile name used by [CNC](https://github.com/citrix/citrix-k8s-node-controller) to configure Citrix ADC VPX or MPX which is deployed as Ingress Gateway  | null            | Optional|
| `ingressGateway.multiClusterIngress `          | Flag indicating if Citrix ADC is acting as Ingress gateway to multi cluster Istio mesh installation. Possible values: true/false | false            | Optional|
| `ingressGateway.multiClusterListenerPort `          | Port opened on Citrix ADC to enable inter-cluster service to service (E-W) communication | 15443            | Optional|
| `ingressGateway.multiClusterListenerNodePort `          | Nodeport for multiClusterListenerPort in case of Citrix ADC CPX acting as Ingress gateway  | 32443            | Optional|
| `ingressGateway.multiClusterSvcDomain `          | Domain suffix of remote service (deployed in other cluster) used in E-W communication | global            | Optional|
| `ingressGateway.tcpPort` | For exposing multiple TCP ingress                                                                                      | null                                                                 |Optional|
| `istioPilot.name`                 | Name of the Istio Pilot service                                                                                                        | istiod                                                           |Optional|
| `istioPilot.namespace`     | Namespace where Istio Pilot is running                                                                                        | istio-system                                                          |Optional|
| `istioPilot.secureGrpcPort`       | Secure GRPC port where Istiod (Istio Pilot) is listening (default setting)                                                                  | 15012                                                                 |Optional|
| `istioPilot.insecureGrpcPort`      | Insecure GRPC port where Istiod (Istio Pilot) is listening                                                                                  | 15010                                                                 |Optional|
| `istioPilot.SAN`                 | Subject alternative name for Istiod (Istio Pilot) which is the secure production identity framework for everyone (SPIFFE) ID of Istio Pilot                                                        | null |Optional|
| `metricExporter.required`          | Metrics exporter for Citrix ADC                                                                                                    | TRUE                                                                  |Optional|
| `metricExporter.image`             | Image of the Citrix ADC Metrics Exporter                                                                                   | quay.io/citrix/citrix-adc-metrics-exporter:1.4.8                             |Optional|
| `metricExporter.port`              | Port over which Citrix ADC Metrics Exporter collects metrics of Citrix ADC.                                                      | 8888                                                                  |Optional|
| `metricExporter.secure`            | Enables collecting metrics over TLS                                                                                                | YES                                                                    |Optional|
| `metricExporter.logLevel`          | Level of logging in Citrix ADC Metrics Exporter. Possible values are: DEBUG, INFO, WARNING, ERROR, CRITICAL                                       | ERROR                                                                 |Optional|
| `metricExporter.imagePullPolicy`   | Image pull policy for Citrix ADC Metrics Exporter                                                                                       | IfNotPresent                                                          |Optional|
| `certProvider.caAddr`   | Certificate Authority (CA) address issuing certificate to application                           | istiod.istio-system.svc                          | Optional |
| `certProvider.caPort`   | Certificate Authority (CA) port issuing certificate to application                              | 15012 | Optional |
| `certProvider.trustDomain`   | SPIFFE Trust Domain                         | cluster.local | Optional |
| `certProvider.certTTLinHours`   | Validity of certificate generated by xds-adaptor and signed by Istiod (Istio Citadel) in hours. Default is 30 days validity              | 720 | Optional |
| `certProvider.jwtPolicy`   | Service Account token type. Kubernetes platform supports First party tokens and Third party tokens.  | first-party-jwt | Optional |
| `secretName`   | Name of the Kubernetes secret holding Citrix ADC credentials | nslogin | Mandatory for Citrix ADC VPX/MPX |

**Note:** You can use the `values.yaml` file packaged in the chart. This file contains the default configuration values for the chart.
