# Citrix ADC CPX with Citrix Ingress Controller running as sidecar.

In a [Kubernetes](https://kubernetes.io/) or [OpenShift](https://www.openshift.com) cluster, you can deploy [Citrix ADC CPX](https://docs.citrix.com/en-us/citrix-adc-cpx) with Citrix ingress controller as a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/). The Citrix ADC CPX instance is used for load balancing the North-South traffic to the microservices in your cluster. And, the sidecar Citrix ingress controller configures the Citrix ADC CPX.

This Chart bootstraps deployment of Citrix ADC CPX with Citrix Ingress Controller as sidecar.
