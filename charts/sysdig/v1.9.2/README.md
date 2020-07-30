# Chart: Sysdig

[Sysdig](https://sysdig.com/) is a unified platform for container and microservices monitoring, troubleshooting, security and forensics. Sysdig platform has been built on top of [Sysdig tool](https://sysdig.com/opensource/sysdig/) and [Sysdig Inspect](https://sysdig.com/blog/sysdig-inspect/) open-source technologies.

## Introduction

This chart adds the Sysdig agent for [Sysdig Monitor](https://sysdig.com/product/monitor/) and [Sysdig Secure](https://sysdig.com/product/secure/) to all nodes in your cluster via a DaemonSet.

## Prerequisites

- Kubernetes 1.9+ with Beta APIs enabled

## Installing the Chart

To install the chart with the release name `my-release`, retrieve your Sysdig Monitor Access Key from your [Account Settings](https://app.sysdigcloud.com/#/settings/agentInstallation) and run:

```bash
$ helm repo add sysdiglabs https://sysdiglabs.github.io/charts/
```

to add the `sysdiglabs` Helm chart repository. Then run:

```bash
$ helm install --name my-release --set sysdig.accessKey=YOUR-KEY-HERE sysdiglabs/sysdig
```

After a few seconds, you should see hosts and containers appearing in Sysdig Monitor and Sysdig Secure.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```
> **Tip**: Use helm delete --purge my-release to completely remove the release from Helm internal storage

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Sysdig chart and their default values.

| Parameter                         | Description                                                                             | Default                                     |
| ---                               | ---                                                                                     | ---                                         |
| `image.registry`                  | Sysdig Agent image registry                                                             | `docker.io`                                 |
| `image.repository`                | The image repository to pull from                                                       | `sysdig/agent`                              |
| `image.tag`                       | The image tag to pull                                                                   | `10.3.0`                       |
| `image.pullPolicy`                | The Image pull policy                                                                   | `IfNotPresent`                              |
| `image.pullSecrets`               | Image pull secrets                                                                      | `nil`                                       |
| `resources.requests.cpu`          | CPU requested for being run in a node                                                   | `600m`                                      |
| `resources.requests.memory`       | Memory requested for being run in a node                                                | `512Mi`                                     |
| `resources.limits.cpu`            | CPU limit                                                                               | `2000m`                                     |
| `resources.limits.memory`         | Memory limit                                                                            | `1536Mi`                                    |
| `rbac.create`                     | If true, create & use RBAC resources                                                    | `true`                                      |
| `scc.create`                      | Create OpenShift's Security Context Constraint                                          | `true`                                      |
| `serviceAccount.create`           | Create serviceAccount                                                                   | `true`                                      |
| `serviceAccount.name`             | Use this value as serviceAccountName                                                    | ` `                                         |
| `daemonset.updateStrategy.type`   | The updateStrategy for updating the daemonset                                           | `RollingUpdate`                             |
| `daemonset.affinity`              | Node affinities                                                                         | `schedule on amd64 and linux`               |
| `daemonset.annotations`           | Custom annotations for daemonset                                                        | `{}`                                        |
| `slim.enabled`                    | Use the slim based Sysdig Agent image                                                   | `false`                                     |
| `slim.kmoduleImage.repository`    | The kernel module image builder repository to pull from                                 | `sysdig/agent-kmodule`                      |
| `slim.resources.requests.cpu`     | CPU requested for building the kernel module                                            | `1000m`                                     |
| `slim.resources.requests.memory`  | Memory requested for building the kernel module                                         | `348Mi`                                     |
| `slim.resources.limits.memory`    | Memory limit for building the kernel module                                             | `512Mi`                                     |
| `ebpf.enabled`                    | Enable eBPF support for Sysdig instead of `sysdig-probe` kernel module                  | `false`                                     |
| `ebpf.settings.mountEtcVolume`    | Needed to detect which kernel version are running in Google COS                         | `true`                                      |
| `clusterName`                     | Set a cluster name to identify events using *kubernetes.cluster.name* tag               | ` `                                         |
| `sysdig.accessKey`                | Your Sysdig Monitor Access Key                                                          | `Nil` You must provide your own key         |
| `sysdig.disableCaptures`          | Disable capture functionality (see https://docs.sysdig.com/en/disable-captures.html)    | `false`                                     |
| `sysdig.settings`                 | Additional settings, directly included in the agent's configuration file `dragent.yaml` | `{}`                                        |
| `secure.enabled`                  | Enable Sysdig Secure                                                                    | `true`                                      |
| `auditLog.enabled`                | Enable K8s audit log support for Sysdig Secure                                          | `false`                                     |
| `auditLog.auditServerUrl`         | The URL where Sysdig Agent listens for K8s audit log events                             | `0.0.0.0`                                   |
| `auditLog.auditServerPort`        | Port where Sysdig Agent listens for K8s audit log events                                | `7765`                                      |
| `auditLog.dynamicBackend.enabled` | Deploy the Audit Sink where Sysdig listens for K8s audit log events                     | `false`                                     |
| `customAppChecks`                 | The custom app checks deployed with your agent                                          | `{}`                                        |
| `nodeImageAnalyzer.deploy`        | Deploy the Node Image Analyzer (See https://docs.sysdig.com/en/scan-running-images.html)| `false`                                     |
| `nodeImageAnalyzer.image.repository`          | The image repository to pull the Node Image Analyzer from                   | `sysdig/node-image-analyzer`                |
| `nodeImageAnalyzer.image.tag`                 | The image tag to pull the Node Image Analyzer                               | `0.1.1`                                     |
| `nodeImageAnalyzer.image.pullPolicy`          | The Image pull policy for the Node Image Analyzer                           | `IfNotPresent`                              |
| `nodeImageAnalyzer.image.pullSecrets`         | Image pull secrets for the Node Image Analyzer                              | `nil`                                       |
| `nodeImageAnalyzer.resources.requests.cpu`    | Node Image Analyzer CPU requests per node                                   | `250m`                                      |
| `nodeImageAnalyzer.resources.requests.memory` | Node Image Analyzer Memory requests per node                                | `512Mi`                                     |
| `nodeImageAnalyzer.resources.limits.cpu`      | Node Image Analyzer CPU limit per node                                      | `500m`                                      |
| `nodeImageAnalyzer.resources.limits.memory`   | Node Image Analyzer Memory limit per node                                   | `1024Mi`                                    |
| `nodeImageAnalyzer.settings`      | Additional Node Image Analyzer settings                                                 | `{}`                                        |
| `tolerations`                     | The tolerations for scheduling                                                          | `node-role.kubernetes.io/master:NoSchedule` |
| `prometheus.file`                 | Use file to configure promscrape                                                        | `false`                                     |
| `prometheus.yaml`                 | prometheus.yaml content to configure metric collection: relabelling and filtering       | ` `                                         |
| `extraVolume.volumes`             | Additional volumes to mount in the sysdig agent to pass new secrets or configmaps       | `[]`                                        |
| `extraVolume.mounts`              | Mount points for additional volumes                                                     | `[]`                                        |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
    --set sysdig.accessKey=YOUR-KEY-HERE,sysdig.settings.tags="role:webserver\,location:europe" \
    sysdiglabs/sysdig
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml sysdiglabs/sysdig
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## On-Premise backend deployment settings

Sysdig platform backend can be also deployed On-Premise in your own infrastructure.

Installing the agent using the Helm chart is also possible in this scenario, and you can enable it with the following parameters:

| Parameter                                | Description                                              | Default |
| ---                                      | ---                                                      | ---     |
| `collectorSettings.collectorHost`        | The IP address or hostname of the collector              | ` `     |
| `collectorSettings.collectorPort`        | The port where collector is listening                    | 6443    |
| `collectorSettings.ssl`                  | The collector accepts SSL                                | `true`  |
| `collectorSettings.sslVerifyCertificate` | Set to false if you don't want to verify SSL certificate | `true`  |

For example:

```bash
$ helm install --name my-release \
    --set sysdig.accessKey=YOUR-KEY-HERE \
    --set collectorSettings.collectorHost=42.32.196.18 \
    --set collectorSettings.collectorPort=6443 \
    --set collectorSettings.sslVerifyCertificate=false \
    sysdiglabs/sysdig
```

## Using private Docker image registry

If you pull the Sysdig agent Docker image from a private registry that requires authentication, some additional configuration is required.

First, create a secret that stores the registry credentials:

```bash
$ kubectl create secret docker-registry SECRET_NAME \
  --docker-server=SERVER \
  --docker-username=USERNAME \
  --docker-password=TOKEN \
  --docker-email=EMAIL
```

Then, point to this secret in the values YAML file:

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
image:
  registry: myrepo.mydomain.tld
  repository: sysdig-agent
  tag: latest-tag
  pullSecrets:
    - name: SECRET_NAME
```

Finally, set the accessKey value and you are ready to deploy the Sysdig agent
using the Helm chart:

```bash
$ helm install --name my-release -f values.yaml sysdiglabs/sysdig
```

You can read more details about this in [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

## Modifying Sysdig agent configuration

The Sysdig agent uses a file called `dragent.yaml` to store the configuration.

Using the Helm chart, the default configuration settings can be updated using `sysdig.settings` either via `--set sysdig.settings.key = value` or in the values YAML file. For example, to eanble Prometheus metrics scraping, you need this in your `values.yaml` file::

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    prometheus:
      enabled: true
      histograms: true
```

```bash
$ helm install --name my-release -f values.yaml sysdiglabs/sysdig
```

## Upgrading Sysdig agent configuration

If you need to upgrade the agent configuration file, first modify the YAML file (in this case we are increasing the metrics limit scraping Prometheus metrics):

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    prometheus:
      enabled: true
      histograms: true
      max_metrics: 2000
      max_metrics_per_process: 400
```

And then, upgrade Helm chart with:

```bash
$ helm upgrade my-release -f values.yaml sysdiglabs/sysdig
```

## How to upgrade to the last version

First of all ensure you have the lastest chart version

```bash
$ helm repo update
```

In case you deployed the chart with a values.yaml file, you just need to modify (or add if it's missing) the `image.tag` field and execute:

```bash
$ helm install --name sysdig -f values.yaml sysdiglabs/sysdig
```

If you deployed the chart setting the values as CLI parameters, like for example:

```bash
$ helm install \
    --name sysdig \
    --set sysdig.accessKey=xxxx \
    --set ebpf.enabled=true \
    --namespace sysdig-agent \
    sysdiglabs/sysdig
```

You will need to execute:

```bash
$ helm upgrade --set image.tag=<last_version> --reuse-values sysdig sysdiglabs/sysdig
```

## Adding custom AppChecks

[Application checks](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/204767363/) are integrations that allow the Sysdig agent to collect metrics exposed by specific services. Sysdig has several built-in AppChecks, but sometimes you might need to [create your own](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/204767436/).

Your own AppChecks can deployed with the Helm chart embedding them in the values YAML file:

```yaml
customAppChecks:
  sample.py: |-
    from checks import AgentCheck

    class MyCustomCheck(AgentCheck):
        def check(self, instance):
            self.gauge("testhelm", 1)

sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    app_checks:
      - name: sample
        interval: 10
        pattern: # pattern to match the application
          comm: myprocess
        conf:
          mykey: myvalue
```

The first section, dumps the AppCheck in a Kubernetes configmap and makes it available within the Sysdig agent container. The second, configures it on the `dragent.yaml` file.

Once the values YAML file is ready, we will deploy the Chart like before:

```bash
$ helm install --name my-release -f values.yaml sysdiglabs/sysdig
```

### Automating the generation of custom-app-checks.yaml file

Sometimes editing and maintaining YAML files can be a bit cumbersome and error-prone, so we have created a script for automating this process and make your life easier.

Imagine that you have custom AppChecks for a number of services like Redis, MongoDB and Traefik.

You have already a `values.yaml` with just your configuration:

```yaml
sysdig:
  accessKey: YOUR-KEY-HERE
  settings:
    app_checks:
      - name: myredis
        [...]
      - name: mymongo
        [...]
      - name: mytraefik
        [...]
```

You can generate an additional values YAML file with the custom AppChecks:

```bash
$ git clone https://github.com/kubernetes/charts.git
$ cd charts/sysdiglabs/sysdig
$ ./scripts/appchecks2helm appChecks/solr.py appChecks/traefik.py appChecks/nats.py > custom-app-checks.yaml
```

And deploy the Chart with both of them:

```bash
$ helm install --name my-release -f custom-app-checks.yaml -f values.yaml sysdiglabs/sysdig
```

### Adding prometheus.yaml to configure promscrape

Promscrape is the component used to collect Prometheus metrics from the sysdig agent. It is based on Prometheus and accepts the same configuration format.

This file can contain relabelling rules and filters to remove certain metrics or add some configurations to the collection. An example of this file could be:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
scrape_configs:
- job_name: 'prometheus' # config for federation
  honor_labels: true
  metrics_path: '/federate'
  metric_relabel_configs:
  - regex: 'kubernetes_pod_name'
    action: labeldrop
  params:
    'match[]':
      - '{sysdig="true"}'
  sysdig_sd_configs:
  - tags:
      namespace: monitoring
      deployment: prometheus-server
```
`sysdig_sd_configs` allows to select the targets obtained by Sysdig agents to apply the rules in the job. Check [how to configure filtering in sysdig documentation](https://docs.sysdig.com/en/filtering-prometheus-metrics.html).


### Adding additional volumes

To add a new volume to the sysdig agent.

In order to pass new config maps or secrets used for authentication (for example for Prometheus endpoints) you can mount additional secrets, configmaps or volumes. An example of this could be:

```yaml
extraVolumes:
  volumes:
    - name: sysdig-new-cm
      configMap:
        name: my-cm
        optional: true
    - name: sysdig-new-secret
        secret:
        secretName: my-secret
  mounts:
    - mountPath: /opt/draios/cm
      name: sysdig-new-cm
    - mountPath: /opt/draios/secret
      name: sysdig-new-secret
```

## Support

For getting support from the Sysdig team, you should refer to the official
[Sysdig Support page](https://sysdig.com/support).

In addition to this, you can browse the documentation for the different
components of the Sysdig Platform:

* [Sysdig Monitor](https://app.sysdigcloud.com)
* [Sysdig Secure](https://secure.sysdig.com)
* [Platform Documentation](https://docs.sysdig.com/en/sysdig-platform.html)
* [Monitor Documentation](https://docs.sysdig.com/en/sysdig-monitor.html)
* [Secure Documentation](https://docs.sysdig.com/en/sysdig-secure.html)
