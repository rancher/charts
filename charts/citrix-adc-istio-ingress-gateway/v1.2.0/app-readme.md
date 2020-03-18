# Citrix ADC as an Ingress Gateway for Istio

An [Istio](https://istio.io/) ingress gateway acts as an entry point for the incoming traffic and secures and controls access to the service mesh. It also performs routing and load balancing. Citrix ADC [CPX](https://docs.citrix.com/en-us/citrix-adc-cpx), MPX, or [VPX](https://docs.citrix.com/en-us/citrix-adc.html), can be deployed as an ingress gateway to the Istio service mesh.

### Prerequisites

The following prerequisites are required for deploying Citrix ADC as an Ingress Gateway in Istio service mesh:

- Ensure that **Istio** is enabled.
- Ensure that your cluster has Kubernetes version 1.14.0 or later.
- Ensure to create secret named **nslogin**  with username and password in same namespace in case of VPX/MPX . Choose the **Resources > Secrets** in the navigation bar.

### Important NOTE:
- Follow this [link](https://github.com/citrix/citrix-helm-charts/blob/master/examples/citrix-adc-in-istio/README.md
) to deploy Citrix ADC as an ingress gateway for application.
- For deploying Citrix ADC VPX or MPX as ingress gateway, you should establish the connectivity between Citrix ADC VPX or MPX and cluster nodes. This connectivity can be established by configuring routes on Citrix ADC as mentioned [here](https://github.com/citrix/citrix-k8s-ingress-controller/blob/master/docs/network/staticrouting.md) or by deploying [Citrix Node Controller](https://github.com/citrix/citrix-k8s-node-controller).

This catalog deploys Citrix ADC VPX, MPX, or CPX as an Ingress Gateway in the Istio service mesh. For detailed information on various deployment options,checkout this [link](https://github.com/citrix/citrix-istio-adaptor).
