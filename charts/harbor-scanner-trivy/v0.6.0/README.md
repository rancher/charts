# Harbor Scanner Trivy

Trivy as a plug-in vulnerability scanner in the Harbor registry.

## TL;DR;

### Without TLS

```
$ helm install harbor-scanner-trivy . --namespace harbor
```

### With TLS

1. Generate certificate and private key files:
   ```
   $ openssl genrsa -out tls.key 2048
   $ openssl req -new -x509 \
                 -key tls.key \
                 -out tls.crt \
                 -days 365 \
                 -subj /CN=harbor-scanner-trivy.harbor
   ```
2. Install the `harbor-scanner-trivy` chart:
   ```
   $ helm install harbor-scanner-trivy . \
                  --namespace harbor \
                  --set service.port=8443 \
                  --set scanner.api.tlsEnabled=true \
                  --set scanner.api.tlsCertificate="`cat tls.crt`" \
                  --set scanner.api.tlsKey="`cat tls.key`"
   ```

## Introduction

This chart bootstraps a scanner adapter deployment on a [Kubernetes](http://kubernetes.io) cluster using the
[Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+
- Helm 2.11+ or Helm 3+

## Installing the Chart

To install the chart with the release name `my-release`:

```
$ helm install my-release .
```

The command deploys scanner adapter on the Kubernetes cluster in the default configuration. The [Parameters](#parameters)
section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following table lists the configurable parameters of the scanner adapter chart and their default values.

|                 Parameter             |                                Description                              |    Default     |
|---------------------------------------|-------------------------------------------------------------------------|----------------|
| `image.registry`                      | Image registry                                                          | `docker.io`    |
| `image.repository`                    | Image name                                                              | `aquasec/harbor-scanner-trivy` |
| `image.tag`                           | Image tag                                                               | `{TAG_NAME}`   |
| `image.pullPolicy`                    | Image pull policy                                                       | `IfNotPresent` |
| `replicaCount`                        | Number of scanner adapter Pods to run                                   | `1`            |
| `scanner.logLevel`                    | The log level of `trace`, `debug`, `info`, `warn`, `warning`, `error`, `fatal` or `panic`. The standard logger logs entries with that level or anything above it   | `info` |
| `scanner.api.tlsEnabled`              | The flag to enable or disable TLS for HTTP                              | `true`         |
| `scanner.api.tlsCertificate`          | The absolute path to the x509 certificate file                          |                |
| `scanner.api.tlsKey`                  | The absolute path to the x509 private key file                          |                |
| `scanner.api.readTimeout`             | The maximum duration for reading the entire request, including the body | `15s`          |
| `scanner.api.writeTimeout`            | The maximum duration before timing out writes of the response           | `15s`          |
| `scanner.api.idleTimeout`             | The maximum amount of time to wait for the next request when keep-alives are enabled | `60s` |
| `scanner.trivy.cacheDir`              | Trivy cache directory                                                   | `/home/scanner/.cache/trivy`   |
| `scanner.trivy.reportsDir`            | Trivy reports directory                                                 | `/home/scanner/.cache/reports` |
| `scanner.trivy.debugMode`             | The flag to enable or disable Trivy debug mode                          | `false` |
| `scanner.trivy.vulnType`              | Comma-separated list of vulnerability types. Possible values are `os` and `library`. | `os,library` |
| `scanner.trivy.severity`              | Comma-separated list of vulnerabilities severities to be displayed      | `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL` |
| `scanner.trivy.ignoreUnfixed`         | The flag to display only fixed vulnerabilities                          | `false`        |
| `scanner.trivy.skipUpdate`            | The flag to enable or disable Trivy DB downloads from GitHub            | `false`        |
| `scanner.trivy.gitHubToken`           | The GitHub access token to download Trivy DB                            |      |
| `scanner.trivy.insecure`              | The flag to skip verifying registry certificate                         | `false` |
| `scanner.store.redisURL`              | Redis server URI for a redis store                                      | `redis://harbor-harbor-redis:6379` |
| `scanner.store.redisNamespace`        | A namespace for keys in a redis store                                   | `harbor.scanner.trivy:store`       |
| `scanner.store.redisMaxActive`        | The max number of connections allocated by the pool for a redis store   | `5`  |
| `scanner.store.redisMaxIdle`          | The max number of idle connections in the pool for a redis store        | `5`  |
| `scanner.store.redisScanJobTTL`       | The time to live for persisting scan jobs and associated scan reports   | `1h` |
| `scanner.jobQueue.redisURL`           | Redis server URI for a jobs queue                                       | `redis://harbor-harbor-redis:6379` |
| `scanner.jobQueue.redisNamespace`     | A namespace for keys in a jobs queue                                    | `harbor.scanner.trivy:job-queue`   |
| `scanner.jobQueue.redisPoolMaxActive` | The max number of connections allocated by the pool for a jobs queue    | `5` |
| `scanner.jobQueue.redisPoolMaxIdle`   | The max number of idle connections in the pool for a jobs queue         | `5` |
| `scanner.jobQueue.workerConcurrency`  | The number of workers to spin-up for a jobs queue                       | `1` |
| `service.type`                        | Kubernetes service type                                                 | `LoadBalancer` |
| `service.port`                        | Kubernetes service port                                                 | `8443`         |
| `httpProxy`                           | The URL of the HTTP proxy server                                        |     |
| `httpsProxy`                          | The URL of the HTTPS proxy server                                       |     |
| `noProxy`                             | The URLs that the proxy settings do not apply to                        |     |

The above parameters map to the env variables defined in [harbor-scanner-trivy](https://github.com/aquasecurity/harbor-scanner-trivy#configuration).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

```
$ helm install my-release . \
       --namespace my-namespace \
       --set "service.port=9090" \
       --set "scanner.trivy.vulnType=os\,library"
```
