# Drone.io

[Drone](http://readme.drone.io/) v1 is a Continuous Integration platform built on container technology with native Kubernetes support.

## Installing the Chart
Note: The chart will not install the drone server until you have configured a source control option. If this is the case it will print out notes on how to configure it in place using `helm upgrade`.

In order to not expose your secrets in the Helm release, you can create the secrets upfront and select to use it. e.g,

```console
kubectl create secret generic drone-server-secrets \
      --namespace=drone \
      --from-literal=clientSecret="XXXXXXXXXXXXXXXXXXXXXXXX"
```

Reference the [drone doc](http://readme.drone.io/) for more details.

**WARNING:**
```
It is not recommended to upgrade from earlier (appVersion 0.8.x) versions of Drone due to the large amount of breaking changes both in the product and in the helm charts.
```
