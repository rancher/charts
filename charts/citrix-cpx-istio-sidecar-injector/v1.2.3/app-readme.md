# Citrix ADC as a Sidecar for Istio

Citrix ADC [CPX](https://docs.citrix.com/en-us/citrix-adc-cpx) can act as a sidecar proxy to an application container in Istio. You can inject the Citrix ADC CPX manually or automatically using the [Istio sidecar injector](https://istio.io/docs/setup/additional-setup/sidecar-injection/). 


### Prerequisites

The following prerequisites are required for deploying Citrix ADC as a sidecar in an application pod

- Ensure that **Istio** is enabled.
- Ensure that your cluster has Kubernetes version 1.14.0 or later and the `admissionregistration.k8s.io/v1beta1` API is enabled.
- Ensure the [Kubernetes controller manager](https://rancher.com/docs/rke/latest/en/config-options/services/#kubernetes-controller-manager)’s default certificate signer is enabled.

**Note**: For RKE based cluster, extra arguments need to be provided for kube-controller service.
```services:
  kube-controller: 
    extra_args: 
      cluster-signing-cert-file: "/etc/kubernetes/ssl/kube-ca.pem"
      cluster-signing-key-file: "/etc/kubernetes/ssl/kube-ca-key.pem"
```
For detailed information follow this [link](https://github.com/citrix/citrix-xds-adaptor/blob/master/docs/istio-integration/rancher-provisioned-cluster.md)

### Important NOTE:
 - We should not **Enable Istio Auto Injection** on Application namespace.
 - The cpx-injection=enabled label is mandatory for injecting sidecars.
 - An example to deploy application along with Citrix ADC CPX sidecar is provided [here](https://github.com/citrix/citrix-helm-charts/blob/master/examples/citrix-adc-in-istio/README.md).

This catalog create resources required for automatically deploying Citrix ADC CPX as a sidecar proxy.For detailed information follow this [link](https://github.com/citrix/citrix-helm-charts/tree/master/citrix-cpx-istio-sidecar-injector)
