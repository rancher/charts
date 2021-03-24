# Instana

Instana is an [APM solution](https://www.instana.com/) built for microservices that enables IT Ops to build applications faster and deliver higher quality services by automating monitoring, tracing and root cause analysis.
This solution is optimized for [Kubernetes](https://www.instana.com/automatic-kubernetes-monitoring/).

This chart adds the Instana Agent to all schedulable nodes in your cluster via a privileged `DaemonSet` and accompanying resources like `ConfigurationMap`s, `Secret`s and RBAC settings.

## Prerequisites

* Kubernetes 1.9.x - 1.18.x OR OpenShift 4.x
* Helm 3

## Installation

To configure the installation you can either specify the options on the command line using the **--set** switch, or you can edit **values.yaml**.

First, create a namespace for the instana-agent

```bash
kubectl create namespace instana-agent
```

To install the chart with the release name `instana-agent` and set the values on the command line run:

```bash
$ helm install instana-agent --namespace instana-agent \
--repo https://agents.instana.io/helm \
--set agent.key=INSTANA_AGENT_KEY \
--set agent.endpointHost=HOST \
--set zone.name=ZONE_NAME \
instana-agent
```

**OpenShift:** When targetting an OpenShift 4.x cluster, add `--set openshift=true`.

### Required Settings

#### Configuring the Instana Backend

In order to report the data it collects to the Instana backend for analysis, the Instana agent must know which backend to report to, and which credentials to use to authenticate, known as "agent key".

As described by the [Install Using the Helm Chart](https://www.instana.com/docs/setup_and_manage/host_agent/on/kubernetes#install-using-the-helm-chart) documentation, you will find the right values for the following fields inside Instana itself:

* `agent.endpointHost`
* `agent.endpointPort`
* `agent.key`

_Note:_ You can find the options mentioned in the [configuration section below](#configuration)

If your agents report into a self-managed Instana unit (also known as "on-prem"), you will also need to configure a "download key", which allows the agent to fetch its components from the Instana repository.
The download key is set via the following value:

* `agent.downloadKey`

#### Zone and Cluster

Instana needs to know how to name your Kubernetes cluster and, optionally, how to group your Instana agents in [Custom zones](https://www.instana.com/docs/setup_and_manage/host_agent/configuration/#custom-zones) using the following fields:

* `zone.name`
* `cluster.name`

Either `zone.name` or `cluster.name` are required.
If you omit `cluster.name`, the value of `zone.name` will be used as cluster name as well.
If you omit `zone.name`, the host zone will be automatically determined by the availability zone information provided by the [supported Cloud providers](https://www.instana.com/docs/setup_and_manage/cloud_service_agents).

## Uninstallation

To uninstall/delete the `instana-agent` release:

```bash
helm del instana-agent -n instana-agent
```

## Configuration Reference

The following table lists the configurable parameters of the Instana chart and their default values.

|             Parameter              |            Description                                                  |                    Default                                                                                  |
|------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `agent.configuration_yaml`         | Custom content for the agent configuration.yaml file                    | `nil` See [below](#agent) for more details                                                                  |
| `agent.configuration.autoMountConfigEntries` | (Experimental, needs Helm 3.1+) Automatically look up the entries of the default `instana-agent` ConfigMap, and mount as agent configuration files in the `instana-agent` container under the `/opt/instana/agent/etc/instana` directory all ConfigMap entries with keys that match the `configuration-*.yaml` scheme. | `false`
| `agent.endpointHost`               | Instana Agent backend endpoint host                                     | `ingress-red-saas.instana.io` (US and ROW). If in Europe, please override with `ingress-blue-saas.instana.io`                   |
| `agent.endpointPort`               | Instana Agent backend endpoint port                                     | `443`                                                                                                       |
| `agent.key`                        | Your Instana Agent key                                                  | `nil` You must provide your own key unless `agent.keysSecret` is specified |
| `agent.downloadKey`                | Your Instana Download key                                               | `nil` Usually not required                                                                                  |
| `agent.keysSecret`                 | As an alternative to specifying `agent.key` and, optionally, `agent.downloadKey`, you can instead specify the name of the secret in the namespace in which you install the Instana agent that carries the agent key and download key | `nil` Usually not required, see [Bring your own Keys secret](#bring-your-own-keys-secret) for more details |
| `agent.additionalBackends`         | List of additional backends to report to; it must specify the `endpointHost` and `key` fields, and optionally `endpointPort` | `[]` Usually not required; see [Configuring Additional Backends](#configuring-additional-backends) for more info and examples |
| `agent.image.name`                 | The image name to pull                                                  | `instana/agent`                                                                                             |
| `agent.image.digest`               | The image digest to pull; if specified, it causes `agent.image.tag` to be ignored                                       | `nil`                                                                                                    |
| `agent.image.tag`                  | The image tag to pull; this property is ignored if `agent.image.digest` is specified                                               | `latest`                                                                                                    |
| `agent.image.pullPolicy`           | Image pull policy                                                       | `Always`                                                                                                    |
| `agent.image.pullSecrets`          | Image pull secrets; if not specified (default) _and_ `agent.image.name` starts with `containers.instana.io`, it will be automatically set to `[{ "name": "containers-instana-io" }]` to match the default secret created in this case. | `nil`                                                                                                    |
| `agent.listenAddress`              | List of addresses to listen on, or "*" for all interfaces               | `nil`                                                                                                       |
| `agent.mode`                       | Agent mode. Supported values are `APM`, `INFRASTRUCTURE`, `AWS`         | `APM`                                                                                                 |
| `agent.updateStrategy.type`        | [Daemonet update strategy type](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/); valid values are `OnDelete` and `RollingUpdate` | `RollingUpdate` |
| `agent.updateStrategy.rollingUpdate.maxUnavailable` | How many agent pods can be updated at once; this value is ignored if `agent.updateStrategy.type` is different than `RollingUpdate` | `1` |
| `agent.pod.annotations`            | Additional annotations to apply to the pod                              | `{}`                                                                                                        |
| `agent.pod.priorityClassName`      | Name of an _existing_ PriorityClass that should be set on the agent pods | `nil`                                                                                                      |
| `agent.proxyHost`              | Hostname/address of a proxy                                             | `nil`                                                                                                       |
| `agent.proxyPort`              | Port of a proxy                                                         | `nil`                                                                                                       |
| `agent.proxyProtocol`          | Proxy protocol. Supported proxy types are `http` (for both HTTP and HTTPS proxies), `socks4`, `socks5`.   | `nil`                                                         |
| `agent.proxyUser`              | Username of the proxy auth                                              | `nil`                                                                                                       |
| `agent.proxyPassword`          | Password of the proxy auth                                              | `nil`                                                                                                       |
| `agent.proxyUseDNS`            | Boolean if proxy also does DNS                                          | `nil`                                                                                                       |
| `agent.pod.limits.cpu`             | Container cpu limits in cpu cores                                       | `1.5`                                                                                                       |
| `agent.pod.limits.memory`          | Container memory limits in MiB                                          | `512Mi`                                                                                                       |
| `agent.pod.requests.cpu`           | Container cpu requests in cpu cores                                     | `0.5`                                                                                                       |
| `agent.pod.requests.memory`        | Container memory requests in MiB                                        | `512Mi`                                                                                                       |
| `agent.pod.tolerations`            | Tolerations for pod assignment                                          | `[]` |
| `agent.pod.affinity`               | Affinity for pod assignment                                             | `{}` |
| `agent.env`                        | Additional environment variables for the agent                          | `{}` |
| `agent.redactKubernetesSecrets`    | Enable additional secrets redaction for selected Kubernetes resources   | `nil` See [Kubernetes secrets](https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/#secrets) for more details.   |
| `cluster.name`                     | Display name of the monitored cluster                                   | Value of `zone.name`                                                                                        |
| `leaderElector.port`               | Instana leader elector sidecar port                                     | `42655`                                                                                                     |
| `leaderElector.image.name`         | The elector image name to pull                                          | `instana/leader-elector`                                                                                             |
| `leaderElector.image.digest`               | The image digest to pull; if specified, it causes `leaderElector.image.tag` to be ignored                                       | `nil`                                                                                                    |
| `leaderElector.image.tag`                  | The image tag to pull; this property is ignored if `leaderElector.image.digest` is specified                                               | `latest` |
| `kubernetes.deployment.enabled`          | Isolate kubernetes sensor with a deployment (tech preview)                                           | `false`                                                                                                    |
| `kubernetes.deployment.pod.limits.cpu`     | CPU request for the `kubernetes-sensor` pods (tech preview)                                           | `4`                                                                                                    |
| `kubernetes.deployment.pod.limits.memory`     | Memory request limits for the `kubernetes-sensor` pods (tech preview)                                           | `6144Mi`                                                                                                    |
| `kubernetes.deployment.pod.requests.cpu`     | CPU limit for the `kubernetes-sensor` pods (tech preview)                                           | `1.5`                                                                                                    |
| `kubernetes.deployment.pod.requests.memory`     | Memory limit for the `kubernetes-sensor` pods (tech preview)                                           | `1024Mi`                                                                                                    |
| `podSecurityPolicy.enable`         | Whether a PodSecurityPolicy should be authorized for the Instana Agent pods. Requires `rbac.create` to be `true` as well. | `false` See [PodSecurityPolicy](https://docs.instana.io/setup_and_manage/host_agent/on/kubernetes/#podsecuritypolicy) for more details. |
| `podSecurityPolicy.name`           | Name of an _existing_ PodSecurityPolicy to authorize for the Instana Agent pods. If not provided and `podSecurityPolicy.enable` is `true`, a PodSecurityPolicy will be created for you. | `nil` |
| `rbac.create`                      | Whether RBAC resources should be created                                | `true`                                                                                                      |
| `openshift`                        | Whether to install the Helm chart as needed in OpenShift; this setting implies `rbac.create=true` | `false` |
| `opentelemetry.enabled` | Whether to configure the agent to accept telemetry from OpenTelemetry applications. This option also implies `service.create=true`, and requires Kubernetes 1.17+, as it relies on `topologyKeys`.                              | `false` |
| `prometheus.remoteWrite.enabled` | Whether to configure the agent to accept metrics over its implementation of the `remote_write` Prometheus endpoint. This option also implies `service.create=true`, and requires Kubernetes 1.17+, as it relies on `topologyKeys`.                              | `false` |
| `service.create`            | Whether to create a service that exposes the agents' Prometheus, OpenTelemetry and other APIs inside the cluster. Requires Kubernetes 1.17+, as it relies on `topologyKeys`.                              | `false`                                                                                                      |
| `serviceAccount.create`            | Whether a ServiceAccount should be created                              | `true`                                                                                                      |
| `serviceAccount.name`              | Name of the ServiceAccount to use                                       | `instana-agent`                                                                                             |
| `zone.name`                        | Zone that detected technologies will be assigned to                     | `nil` You must provide either `zone.name` or `cluster.name`, see [above](#installing-the-chart) for details |

### Agent Modes

Agent can have either `APM` or `INFRASTRUCTURE`.
Default is APM and if you want to override that, ensure you set value:

* `agent.mode`

For more information on agent modes, refer to the [Host Agent Modes](https://www.instana.com/docs/setup_and_manage/host_agent#host-agent-modes) documentation.

### Agent Configuration

Besides the settings listed above, there are many more settings that can be applied to the agent via the so-called "Agent Configuration File", often also referred to as `configuration.yaml` file.
An overview of the settings that can be applied is provided in the [Agent Configuration File](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#agent-configuration-file) documentation.
To configure the agent, you can either:

* edit the [config map](templates/configmap.yaml), or
* provide the configuration via the `agent.configuration_yaml` parameter in [values.yaml](values.yaml)

This configuration will be used for all Instana Agents on all nodes. Visit the [agent configuration documentation](https://docs.instana.io/setup_and_manage/host_agent/#agent-configuration-file) for more details on configuration options.

_Note:_ This Helm Chart does not support configuring [Multiple Configuration Files](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#multiple-configuration-files).

### Agent Pod Sizing

The `agent.pod.requests.cpu`, `agent.pod.requests.memory`, `agent.pod.limits.cpu` and `agent.pod.limits.memory` settings allow you to change the sizing of the `instana-agent` pods.
If you are using the [Kubernetes Sensor Deployment](#kubernetes-sensor-deployment) functionality, you may be able to reduce the default amount of resources, and especially memory, allocated to the Instana agents that monitor your applications.
Actual sizing data depends very much on how many pods, containers and applications are monitored, and how much traces they generate, so we cannot really provide a rule of thumb for the sizing.

### Bring your own Keys secret

In case you have automation that creates secrets for you, it may not be desirable for this Helm chart to create a secret containing the `agent.key` and `agent.downloadKey`.
In this case, you can instead specify the name of an alread-existing secret in the namespace in which you install the Instana agent that carries the agent key and download key.

The secret you specify The secret you specify _must_ have a field called `key`, which would contain the value you would otherwise set to `agent.key`, and _may_ contain a field called `downloadKey`, which would contain the value you would otherwise set to `agent.downloadKey`.

### Configuring Additional Configuration Files

[Multiple configuration files](https://www.instana.com/docs/setup_and_manage/host_agent/configuration#multiple-configuration-files) is a capability of the Instana agent that allows for modularity in its configurations files.

The experimental `agent.configuration.autoMountConfigEntries`, which uses functionality available in Helm 3.1+ to automatically look up the entries of the default `instana-agent` ConfigMap, and mount as agent configuration files in the `instana-agent` container under the `/opt/instana/agent/etc/instana` directory all ConfigMap entries with keys that match the `configuration-*.yaml` scheme.

**IMPORTANT:** Needs Helm 3.1+ as it is built on the `lookup` function
**IMPORTANT:** Editing the ConfigMap adding keys requires a `helm upgrade` to take effect

### Configuring Additional Backends

You may want to have your Instana agents report to multiple backends.
The first backend must be configured as shown in the [Configuring the Instana Backend](#configuring-the-instana-backend); every backend after the first, is configured in the `agent.additionalBackends` list in the [values.yaml](values.yaml) as follows:

```yaml
agent:
  additionalBackends:
  # Second backend
  - endpointHost: my-instana.instana.io # endpoint host; e.g., my-instana.instana.io
    endpointPort: 443 # default is 443, so this line could be omitted
    key: ABCDEFG # agent key for this backend
  # Third backend
  - endpointHost: another-instana.instana.io # endpoint host; e.g., my-instana.instana.io
    endpointPort: 1444 # default is 443, so this line could be omitted
    key: LMNOPQR # agent key for this backend
```

The snippet above configures the agent to report to two additional backends.
The same effect as the above can be accomplished via the command line via:

```sh
$ helm install -n instana-agent instana-agent ... \
    --repo https://agents.instana.io/helm \
    --set 'agent.additionalBackends[0].endpointHost=my-instana.instana.io' \
    --set 'agent.additionalBackends[0].endpointPort=443' \
    --set 'agent.additionalBackends[0].key=ABCDEFG' \
    --set 'agent.additionalBackends[1].endpointHost=another-instana.instana.io' \
    --set 'agent.additionalBackends[1].endpointPort=1444' \
    --set 'agent.additionalBackends[1].key=LMNOPQR' \
    instana-agent
```

_Note:_ There is no hard limitation on the number of backends an Instana agent can report to, although each comes at the cost of a slight increase in CPU and memory consumption.

### Configuring a Proxy between the Instana agents and the Instana backend

If your infrastructure uses a proxy, you should ensure that you set values for:

* `agent.pod.proxyHost`
* `agent.pod.proxyPort`
* `agent.pod.proxyProtocol`
* `agent.pod.proxyUser`
* `agent.pod.proxyPassword`
* `agent.pod.proxyUseDNS`

### Configuring which Networks the Instana Agent should listen on

If your infrastructure has multiple networks defined, you might need to allow the agent to listen on all addresses (typically with value set to `*`):

* `agent.listenAddress`

### Development and debugging options

These options will be rarely used outside of development or debugging of the agent.

|             Parameter              |            Description                                                  |                    Default                                                                                  |
|------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `agent.host.repository`            | Host path to mount as the agent maven repository                        | `nil`                                                                                                       |

### Kubernetes Sensor Deployment

**Note:** This functionality is in Technical Preview.

The data about Kubernetes resources is collected by the Kubernetes sensor in the Instana agent.
With default configurations, only one Instana agent at any one time is capturing the bulk of Kubernetes data.
Which agent gets the task is coordinated by a leader elector mechanism running inside the `leader-elector` container of the `instana-agent` pods.
However, on large Kubernetes clusters, the load on the one Instana agent that fetches the Kubernetes data can be substantial and, to some extent, has lead to rather "generous" resource requests and limits for all the Instana agents across the cluster, as any one of them could become the leader at some point.

The Helm chart has a special mode, enabled by setting `kubernetes.deployment.enabled=true`, that will actually schedule additional Instana agents running _only_ the Kubernetes sensor that run in a dedicated `kubernetes-sensor` Deployment inside the `instana-agent` namespace.
The pods containing agents that run only the Kubernetes sensor are called `kubernetes-sensor` pods.
When `kubernetes.deployment.enabled=true`, the `instana-agent` pods running inside the daemonset do _not_ contain the `leader-elector` container, which is instead scheduled inside the `kubernetes-sensor` pods.

The `instana-agent` and `kubernetes-sensor` pods share the same configurations in terms of backend-related configurations (including [additional backends](#configuring-additional-backends)).

It is advised to use the `kubernetes.deployment.enabled=true` mode on clusters of more than 10 nodes, and in that case, you may be able to reduce the amount of resources assigned to the `instana-agent` pods, especially in terms of memory, using the [Agent Pod Sizing](#agent-pod-sizing) settings.
The `kubernetes.deployment.pod.requests.cpu`, `kubernetes.deployment.pod.requests.memory`, `kubernetes.deployment.pod.limits.cpu` and `kubernetes.deployment.pod.limits.memory` settings, on the other hand, allows you to change the sizing of the `kubernetes-sensor` pods.

## Changelog

### v1.2.9

* Simplify setup for using OpenTelemetry and the Prometheus `remote_write` endpoint using the `opentelemetry.enabled` and `prometheus.remoteWrite.enabled` settings, respectively.

### v1.2.8

* **Technical Preview:** Introduce a new mode of running to the Kubernetes sensor using a dedicated deployment.
  See the [Kubernetes Sensor Deployment](#kubernetes-sensor-deployment) section for more information.

### v1.2.7

* Fix: Make service opt-in, as it uses functionality (`topologyKeys`) that is available only in K8S 1.17+.

### v1.2.6

* Fix bug that might cause some OpenShift-specific resources to be created in other flavours of Kubernetes.

### v1.2.5

* Introduce the `instana-agent:instana-agent` Kubernetes service that allows you to talk to the Instana agent on the same node.

### v1.2.3

* Bug fix: Extend the built-in Pod Security Policy to cover the Docker socket mount for Tanzu Kubernetes Grid systems.

### v1.2.1

* Support OpenShift 4.x: just add --set openshift=true to the usual settings, and off you go :-)
* Restructure documentation for consistency and readability
* Deprecation: Helm 2 is no longer supported; the minimum Helm API version is now v2, which will make Helm 2 refuse to process the chart.

### v1.1.10

* Some linting of the whitespaces in the generated YAML

### v1.1.9

* Update the README to replace all references of `stable/instana-agent` with specifically setting the repo flag to `https://agents.instana.io/helm`.
* Add support for TKGI and PKS systems, providing a workaround for the [unexpected Docker socket location](https://github.com/cloudfoundry-incubator/kubo-release/issues/329).

### v1.1.7

* Store the cluster name in a new `cluster-name` entry of the `instana-agent` ConfigMap rather than directly as the value of the `INSTANA_KUBERNETES_CLUSTER_NAME`, so that you can edit the cluster name in the ConfigMap in deployments like VMware Tanzu Kubernetes Grid in which, when installing the Instana agent over the [Instana tile](https://www.instana.com/docs/setup_and_manage/host_agent/on/vmware_tanzu), you do not have directly control to the configuration of the cluster name.
If you edit the ConfigMap, you will need to delete the `instana-agent` pods for its new value to take effect.

### v1.1.6

* Allow to use user-specified memony measurement units in `agent.pod.requests.memory` and `agent.pod.limits.memory`.
  If the value set is numerical, the Chart will assume it to be expressed in `Mi` for backwards compatibility.
* Exposed `agent.updateStrategy.type` and `agent.updateStrategy.rollingUpdate.maxUnavailable` settings.

### v1.1.5

Restore compatibility with Helm 2 that was broken in v1.1.4 by the usage of the `lookup` function, a function actually introduced only with Helm 3.1.
Coincidentally, this has been an _excellent_ opportunity to introduce `helm lint` to our validation pipeline and end-to-end tests with Helm 2 ;-)

### v1.1.4

* Bring-your-own secret for agent keys: using the new `agent.keysSecret` setting, you can specify the name of the secret that contains the agent key and, optionally, the download key; refer to [Bring your own Keys secret](#bring-your-own-keys-secret) for more details.
* Add support for affinities for the instana agent pod via the `agent.pod.affinity` setting.
* Put some love into the ArtifactHub.io metadata; likely to add some more improvements related to this over time.

### v1.1.3

* No new features, just ironing some wrinkles out of our release automation.

### v1.1.2

* Improvement: Seamless support for Instana static agent images: When using an `agent.image.name` starting with `containers.instana.io`, automatically create a secret called `containers-instana-io` containing the `.dockerconfigjson` for `containers.instana.io`, using `_` as username and `agent.downloadKey` or, if missing, `agent.key` as password. If you want to control the creation of the image pull secret, or disable it, you can use `agent.image.pullSecrets`, passing to it the YAML to use for the `imagePullSecrets` field of the Daemonset spec, including an empty array `[]` to mount no pull secrets, no matter what.

### v1.1.1

* Fix: Recreate the `instana-agent` pods when there is a change in one of the following configuration, which are mapped to the chart-managed ConfigMap:

* `agent.configuration_yaml`
* `agent.additional_backends`

The pod recreation is achieved by annotating the `instana-agent` Pod with a new `instana-configuration-hash` annotation that has, as value, the SHA-1 hash of the configurations used to populate the ConfigMap.
This way, when the configuration changes, the respective change in the `instana-configuration-hash` annotation will cause the agent pods to be recreated.
This technique has been described at [1] (or, at least, that is were we learned about it) and it is pretty cool :-)

### v1.1.0

* Improvement: The `instana-agent` Helm chart has a new home at `https://agents.instana.io/helm` and `https://github.com/instana/helm-charts/instana-agent`!
This release is functionally equivalent to `1.0.34`, but we bumped the major to denote the new location ;-)

## References

[1] ["Using Kubernetes Helm to push ConfigMap changes to your Deployments", by Sander Knape; Mar 7, 2019](https://sanderknape.com/2019/03/kubernetes-helm-configmaps-changes-deployments/)
