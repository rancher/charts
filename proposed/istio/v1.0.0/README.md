## Primary Components

The address below is the link of some primary components of Istio, if you have any questions about them, you can visit,
[Mixer](https://istio.io/docs/concepts/policy-and-control/mixer.html)

[Pilot](https://istio.io/docs/concepts/traffic-management/pilot.html)

[Istio-ingress](https://istio.io/docs/tasks/traffic-management/ingress.html)

[Security](https://istio.io/docs/concepts/security/)


## Manage your own applications using Istio
Once you have deployed the Istio catalog, then you can deploy your own applications or one of the sample applications provided with the installation like [Bookinfo](https://istio.io/docs/guides/bookinfo.html). Note: the application must use HTTP/1.1 or HTTP/2.0 protocol for all its HTTP traffic because HTTP/1.0 is not supported.

Because the deployment does not have the Istio-sidecar-injector installed, so you must use [istioctr kube-inject](https://istio.io/docs/reference/commands/istioctl.html#istioctl%20kube-inject) to manually inject Envoy containers in your application pods before deploying them:

```console
$ kubectl create -f <(istioctl kube-inject -f <your-app-spec>.yaml)
```

[Here](https://istio.io/docs/setup/kubernetes/sidecar-injection.html#manual-sidecar-injection) is the detailed description about how to install the Istio Sidecar.

## Configuration

The following tables lists the configurable parameters of the Istio chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
global.proxy.image |  The image of Istio proxy| `istio/proxy` |
global.proxy.initImage |  The initial image of Istio proxy| `istio/proxy_init` |
global.tag |  The image tag of Istio proxy| `0.7.1` |
mixer.enabled |  Enabled the mixer component of Istio| `true` |
mixer.replicaCount |  The number of mixer pods| `1` |
mixer.image.repository |  The mixer image repository| `istio/mixer` |
mixer.image.tag |  The mixer image tag| `0.7.1` |
mixer.prometheusStatsdExporter.repository | The promutheus stas exporter image repository | `prom/statsd-exporter`
mixer.prometheusStatsdExporter.tag | The prometheus stas exporter image tag | `latest`
pilot.enabled | Enabled the pilot component of istio | `true`
pilot.replicaCount | The number of pilot pods | `1`
pilot.image.repository | The pilot image repository | `istio/pilot`
pilot.image.tag| The pilot image tag | `0.7.1`
grafana.enabled | Enabled the grafana component of istio | `false`
grafana.replicaCount | The number of grafana pods | `1`
grafana.image.repository | The grafana image repository | `istio/grafana`
grafana.image.tag | The grafana image tag| `0.7.1`
grafana.ingress.enabled | Expose grafana using layer 7 load balancer | `false`
grafana.ingress.hosts | The hostname to access the grafana | `grafana.local`
grafana.service.type | Grafana service type | `NodePort`
servicegraph.enabled | Enabled the servicegraph component of istio | `false`
servicegraph.replicaCount | The number of servicegraph pods | `1`
servicegraph.image.repository | The servicegraph image repository | `istio/servicegraph`
servicegraph.image.tag | The servicegraph image tag | `0.7.1`
servicegraph.ingress.enabled | Expose servicegraph using layer 7 load balancer | `false`
servicegraph.ingress.hosts | The hostname to access the servicegraph | `servicegraph.local`
servicegraph.service.type | Servicegraph service type | `NodePort`
zipkin.enabled | Enabled the zipkin component of istio | `false`
zipkin.replicaCount | The number of zipkin pods | `1`
zipkin.image.repository | The zipkin image repository | `openzipkin/zipkin`
zipkin.image.tag | The zipkin image tag | `latest`
zipkin.ingress.enabled | Expose zipkin using layer 7 load balancer | `false`
zipkin.ingress.hosts | The hostname to access the zipkin | `zipkin.local`
zipkin.service.type | zipkin service type | `NodePort`
prometheus.enabled | Enabled the prometheus component of istio | `false`
prometheus.replicaCount | The number of prometheus pods | `1`
prometheus.image.repository | The prometheus image repository | `prom/prometheus`
prometheus.image.tag | The prometheus image tag | `latest`
prometheus.ingress.enabled | Expose prometheus using layer 7 load balancer | `false`
prometheus.ingress.hosts | The hostname to access the prometheus | `prometheus.local`
prometheus.service.nodePort.enabled | Set the service type to `NodePort` | `true`
prometheus.service.nodePort.port | Specify the node port | `32090`
security.replicaCount | The number of security pods | `1`
security.image.repository | The security image repository | `istio/istio-ca`
security.image.tag | The security image tag | `0.7.1`
ingress.enabled | Expose istio using layer 7 load balancer | `true`
ingress.autoscaleMin | The autoscale minimum number of istio ingress | `2`
ingress.autoscaleMax | The autoscale maximum number of istio ingress | `8`
ingress.service.nodePort.enabled | Set the service type to `NodePort`, default `LoadBalancer` | `false`
ingress.service.nodePort.port | Specify the node port | `32000`
