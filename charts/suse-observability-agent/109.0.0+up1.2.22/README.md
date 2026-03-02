# suse-observability-agent

Helm chart for the SUSE observability Agent.

Current chart version is `1.2.22`

**Homepage:** <https://github.com/StackVista/stackstate-agent>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.stackstate.io | httpHeaderInjectorWebhook(http-header-injector) | 0.0.22 |
| https://helm.stackstate.io | kubernetes-rbac-agent | 0.0.23 |

## Required Values

In order to successfully install this chart, you **must** provide the following variables:

* `stackstate.apiKey`
* `stackstate.cluster.name`
* `stackstate.url`

The parameter `stackstate.cluster.name` is entered when installing the Cluster Agent StackPack.

Install them on the command line on Helm with the following command:

```shell
helm install \
--set-string 'stackstate.apiKey'='<your-api-key>' \
--set-string 'stackstate.cluster.name'='<your-cluster-name>' \
--set-string 'stackstate.url'='<your-stackstate-url>' \
stackstate/stackstate-k8s-agent
```

## Recommended Values

It is also recommended that you set a value for `stackstate.cluster.authToken`. If it is not provided, a value will be generated for you, but the value will change each time an upgrade is performed.

The command for **also** installing with a set token would be:

```shell
helm install \
--set-string 'stackstate.apiKey'='<your-api-key>' \
--set-string 'stackstate.cluster.name'='<your-cluster-name>' \
--set-string 'stackstate.cluster.authToken'='<your-cluster-token>' \
--set-string 'stackstate.url'='<your-stackstate-url>' \
stackstate/stackstate-k8s-agent
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| all.fullPrivilegesMode.enabled | bool | `false` | All agent pods run in full privileges mode (mainly used for debugging). |
| all.image.registry | string | `nil` | The image registry to use. |
| checksAgent.affinity | object | `{}` | Affinity settings for pod assignment. |
| checksAgent.checksTagCardinality | string | `"orchestrator"` | low, orchestrator or high. Orchestrator level adds pod_name, high adds display_container_name |
| checksAgent.config | object | `{"override":[]}` |  |
| checksAgent.config.override | list | `[]` | A list of objects containing three keys `name`, `path` and `data`, specifying filenames at specific paths which need to be (potentially) overridden using a mounted configmap |
| checksAgent.enabled | bool | `true` | Enable / disable runnning cluster checks in a separately deployed pod |
| checksAgent.image.pullPolicy | string | `"IfNotPresent"` | Default container image pull policy. |
| checksAgent.image.repository | string | `"stackstate/stackstate-k8s-agent"` | Base container image repository. |
| checksAgent.image.tag | string | `"b85512ad"` | Default container image tag. |
| checksAgent.livenessProbe.enabled | bool | `true` | Enable use of livenessProbe check. |
| checksAgent.livenessProbe.failureThreshold | int | `3` | `failureThreshold` for the liveness probe. |
| checksAgent.livenessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the liveness probe. |
| checksAgent.livenessProbe.periodSeconds | int | `15` | `periodSeconds` for the liveness probe. |
| checksAgent.livenessProbe.successThreshold | int | `1` | `successThreshold` for the liveness probe. |
| checksAgent.livenessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the liveness probe. |
| checksAgent.logLevel | string | `"INFO"` | Logging level for clusterchecks agent processes. |
| checksAgent.nodeSelector | object | `{}` | Node labels for pod assignment. |
| checksAgent.priorityClassName | string | `""` | Priority class for clusterchecks agent pods. |
| checksAgent.readinessProbe.enabled | bool | `true` | Enable use of readinessProbe check. |
| checksAgent.readinessProbe.failureThreshold | int | `3` | `failureThreshold` for the readiness probe. |
| checksAgent.readinessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the readiness probe. |
| checksAgent.readinessProbe.periodSeconds | int | `15` | `periodSeconds` for the readiness probe. |
| checksAgent.readinessProbe.successThreshold | int | `1` | `successThreshold` for the readiness probe. |
| checksAgent.readinessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the readiness probe. |
| checksAgent.replicas | int | `1` | Number of clusterchecks agent pods to schedule |
| checksAgent.resources.limits.cpu | string | `"400m"` | CPU resource limits. |
| checksAgent.resources.limits.memory | string | `"600Mi"` | Memory resource limits. |
| checksAgent.resources.requests.cpu | string | `"20m"` | CPU resource requests. |
| checksAgent.resources.requests.memory | string | `"512Mi"` | Memory resource requests. |
| checksAgent.serviceaccount.annotations | object | `{}` | Annotations for the service account for the cluster checks pods |
| checksAgent.skipSslValidation | bool | `false` | Set to true if self signed certificates are used. |
| checksAgent.strategy | object | `{"type":"RollingUpdate"}` | The strategy for the Deployment object. |
| checksAgent.tolerations | list | `[]` | Toleration labels for pod assignment. |
| clusterAgent.affinity | object | `{}` | Affinity settings for pod assignment. |
| clusterAgent.collection.kubeStateMetrics.annotationsAsTags | object | `{}` | Extra annotations to collect from resources and to turn into tags. |
| clusterAgent.collection.kubeStateMetrics.clusterCheck | bool | `false` | For large clusters where the Kubernetes State Metrics Check Core needs to be distributed on dedicated workers. |
| clusterAgent.collection.kubeStateMetrics.enabled | bool | `true` | Enable / disable the cluster agent kube-state-metrics collection. |
| clusterAgent.collection.kubeStateMetrics.labelsAsTags | object | `{}` | Extra labels to collect from resources and to turn into StackState tag. # It has the following structure: # labelsAsTags: #   <resource1>:        # can be pod, deployment, node, etc. #     <label1>: <tag1>  # where <label1> is the kubernetes label and <tag1> is the StackState tag #     <label2>: <tag2> #   <resource2>: #     <label3>: <tag3> # # Warning: the label must match the transformation done by kube-state-metrics, # for example tags.example/version becomes tags_example_version. |
| clusterAgent.collection.kubernetesEvents | bool | `true` | Enable / disable the cluster agent events collection. |
| clusterAgent.collection.kubernetesMetrics | bool | `true` | Enable / disable the cluster agent metrics collection. |
| clusterAgent.collection.kubernetesResources.configmaps | bool | `true` | Enable / disable collection of ConfigMaps. |
| clusterAgent.collection.kubernetesResources.cronjobs | bool | `true` | Enable / disable collection of CronJobs. |
| clusterAgent.collection.kubernetesResources.daemonsets | bool | `true` | Enable / disable collection of DaemonSets. |
| clusterAgent.collection.kubernetesResources.deployments | bool | `true` | Enable / disable collection of Deployments. |
| clusterAgent.collection.kubernetesResources.endpoints | bool | `true` | Enable / disable collection of Endpoints. If endpoints are disabled it is not possible to connect a Service to Pods that serving it |
| clusterAgent.collection.kubernetesResources.horizontalpodautoscalers | bool | `true` | Enable / disable collection of HorizontalPodAutoscalers. |
| clusterAgent.collection.kubernetesResources.ingresses | bool | `true` | Enable / disable collection of Ingresses. |
| clusterAgent.collection.kubernetesResources.jobs | bool | `true` | Enable / disable collection of Jobs. |
| clusterAgent.collection.kubernetesResources.limitranges | bool | `true` | Enable / disable collection of LimitRanges. |
| clusterAgent.collection.kubernetesResources.namespaces | bool | `true` | Enable / disable collection of Namespaces. |
| clusterAgent.collection.kubernetesResources.persistentvolumeclaims | bool | `true` | Enable / disable collection of PersistentVolumeClaims. Disabling these makes it impossible to create relations between PersistentVolumes and pods |
| clusterAgent.collection.kubernetesResources.persistentvolumes | bool | `true` | Enable / disable collection of PersistentVolumes. |
| clusterAgent.collection.kubernetesResources.poddisruptionbudgets | bool | `true` | Enable / disable collection of PodDisruptionBudgets. |
| clusterAgent.collection.kubernetesResources.replicasets | bool | `true` | Enable / disable collection of ReplicaSets. |
| clusterAgent.collection.kubernetesResources.replicationcontrollers | bool | `true` | Enable / disable collection of ReplicationControllers. |
| clusterAgent.collection.kubernetesResources.resourcequotas | bool | `true` | Enable / disable collection of ResourceQuotas. |
| clusterAgent.collection.kubernetesResources.secrets | bool | `true` | Enable / disable collection of Secrets. |
| clusterAgent.collection.kubernetesResources.statefulsets | bool | `true` | Enable / disable collection of StatefulSets. |
| clusterAgent.collection.kubernetesResources.storageclasses | bool | `true` | Enable / disable collection of StorageClasses. |
| clusterAgent.collection.kubernetesResources.volumeattachments | bool | `true` | Enable / disable collection of Volume Attachments. Used to bind Nodes to Persistent Volumes. |
| clusterAgent.collection.kubernetesTimeout | int | `10` | Default timeout (in seconds) when obtaining information from the Kubernetes API. |
| clusterAgent.collection.kubernetesTopology | bool | `true` | Enable / disable the cluster agent topology collection. |
| clusterAgent.config | object | `{"configMap":{"maxDataSize":null},"events":{"categories":{}},"override":[],"topology":{"collectionInterval":90}}` |  |
| clusterAgent.config.configMap.maxDataSize | string | `nil` | Maximum amount of characters for the data property of a ConfigMap collected by the kubernetes topology check |
| clusterAgent.config.events.categories | object | `{}` | Custom mapping from Kubernetes event reason to StackState event category. Categories allowed: Alerts, Activities, Changes, Others |
| clusterAgent.config.override | list | `[]` | A list of objects containing three keys `name`, `path` and `data`, specifying filenames at specific paths which need to be (potentially) overridden using a mounted configmap |
| clusterAgent.config.topology.collectionInterval | int | `90` | Interval for running topology collection, in seconds |
| clusterAgent.enabled | bool | `true` | Enable / disable the cluster agent. |
| clusterAgent.image.pullPolicy | string | `"IfNotPresent"` | Default container image pull policy. |
| clusterAgent.image.repository | string | `"stackstate/stackstate-k8s-cluster-agent"` | Base container image repository. |
| clusterAgent.image.tag | string | `"b85512ad"` | Default container image tag. |
| clusterAgent.livenessProbe.enabled | bool | `true` | Enable use of livenessProbe check. |
| clusterAgent.livenessProbe.failureThreshold | int | `3` | `failureThreshold` for the liveness probe. |
| clusterAgent.livenessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the liveness probe. |
| clusterAgent.livenessProbe.periodSeconds | int | `15` | `periodSeconds` for the liveness probe. |
| clusterAgent.livenessProbe.successThreshold | int | `1` | `successThreshold` for the liveness probe. |
| clusterAgent.livenessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the liveness probe. |
| clusterAgent.logLevel | string | `"INFO"` | Logging level for stackstate-k8s-agent processes. |
| clusterAgent.nodeSelector | object | `{}` | Node labels for pod assignment. |
| clusterAgent.priorityClassName | string | `""` | Priority class for stackstate-k8s-agent pods. |
| clusterAgent.readinessProbe.enabled | bool | `true` | Enable use of readinessProbe check. |
| clusterAgent.readinessProbe.failureThreshold | int | `3` | `failureThreshold` for the readiness probe. |
| clusterAgent.readinessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the readiness probe. |
| clusterAgent.readinessProbe.periodSeconds | int | `15` | `periodSeconds` for the readiness probe. |
| clusterAgent.readinessProbe.successThreshold | int | `1` | `successThreshold` for the readiness probe. |
| clusterAgent.readinessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the readiness probe. |
| clusterAgent.replicaCount | int | `1` | Number of replicas of the cluster agent to deploy. |
| clusterAgent.resources.limits.cpu | string | `"400m"` | CPU resource limits. |
| clusterAgent.resources.limits.memory | string | `"800Mi"` | Memory resource limits. |
| clusterAgent.resources.requests.cpu | string | `"70m"` | CPU resource requests. |
| clusterAgent.resources.requests.memory | string | `"512Mi"` | Memory resource requests. |
| clusterAgent.service.port | int | `5005` | Change the Cluster Agent service port |
| clusterAgent.service.targetPort | int | `5005` | Change the Cluster Agent service targetPort |
| clusterAgent.serviceaccount.annotations | object | `{}` | Annotations for the service account for the cluster agent pods |
| clusterAgent.skipSslValidation | bool | `false` | If true, ignores the server certificate being signed by an unknown authority. |
| clusterAgent.strategy | object | `{"type":"RollingUpdate"}` | The strategy for the Deployment object. |
| clusterAgent.tolerations | list | `[]` | Toleration labels for pod assignment. |
| fullnameOverride | string | `""` | Override the fullname of the chart. |
| global.apiKey.fromSecret | string | `"{{ include \"stackstate-k8s-agent.secret.internal.name\" . }}"` | The secret from which the receiver api key is taken. Will execute as a template. Overriding this will allow setting the api key from an externally provided secret. The api key will be picked form the STS_API_KEY value |
| global.clusterAgentAuthToken.fromSecret | string | `"{{ include \"stackstate-k8s-agent.secret.internal.name\" . }}"` | The secret from from which the token for authenticating between node and cluster agent will be taken. Overriding this will allow setting the api key from an externally provided secret. The api key will be picked form the STS_CLUSTER_AGENT_AUTH_TOKEN value |
| global.customCertificates | object | `{"configMapName":"","enabled":false,"pemData":""}` | Custom certificates for HTTPS endpoints |
| global.customCertificates.configMapName | string | `""` | Name of existing ConfigMap containing certificates (exclusive with pemData) |
| global.customCertificates.enabled | bool | `false` | Enable custom certificate injection |
| global.customCertificates.pemData | string | `""` | PEM-encoded certificate data (exclusive with configMapName), will be stored as tls.pem |
| global.extraAnnotations | object | `{}` | Extra annotations added ta all resources created by the helm chart |
| global.extraEnv.open | object | `{}` | Extra open environment variables to inject into pods. |
| global.extraEnv.secret | object | `{}` | Extra secret environment variables to inject into pods via a `Secret` object. |
| global.extraLabels | object | `{}` | Extra labels added ta all resources created by the helm chart |
| global.imagePullCredentials | object | `{}` | Globally define credentials for pulling images. |
| global.imagePullSecrets | list | `[]` | Secrets / credentials needed for container image registry. |
| global.imageRegistry | string | `"quay.io"` | The image registry to use. |
| global.proxy.url | string | `""` | Proxy for all traffic to stackstate |
| global.skipSslValidation | bool | `false` | Enable tls validation from client |
| httpHeaderInjectorWebhook.certificatePrehook.image.repository | string | `"stackstate/container-tools"` |  |
| httpHeaderInjectorWebhook.certificatePrehook.image.tag | string | `"1.8.2-bci-517"` |  |
| httpHeaderInjectorWebhook.enabled | bool | `false` | Enable the webhook for injection http header injection sidecar proxy |
| httpHeaderInjectorWebhook.proxy.image.repository | string | `"stackstate/http-header-injector-proxy"` |  |
| httpHeaderInjectorWebhook.proxyInit.image.repository | string | `"stackstate/http-header-injector-proxy-init"` |  |
| httpHeaderInjectorWebhook.sidecarInjector.image.repository | string | `"stackstate/generic-sidecar-injector"` |  |
| kubernetes-rbac-agent.clusterName.fromConfigMap | string | `"{{ include \"stackstate-k8s-agent.clusterName.configmap.internal.name\" . }}"` |  |
| kubernetes-rbac-agent.containers.rbacAgent.affinity | object | `{}` | Set affinity |
| kubernetes-rbac-agent.containers.rbacAgent.env | object | `{}` | Additional environment variables |
| kubernetes-rbac-agent.containers.rbacAgent.image.repository | string | `"stackstate/kubernetes-rbac-agent"` |  |
| kubernetes-rbac-agent.containers.rbacAgent.image.tag | string | `"042257c3-575"` |  |
| kubernetes-rbac-agent.containers.rbacAgent.nodeSelector | object | `{}` | Set a nodeSelector |
| kubernetes-rbac-agent.containers.rbacAgent.podAnnotations | object | `{}` | Additional annotations on the pod |
| kubernetes-rbac-agent.containers.rbacAgent.podLabels | object | `{}` | Additional labels on the pod |
| kubernetes-rbac-agent.containers.rbacAgent.priorityClassName | string | `""` | Set priorityClassName |
| kubernetes-rbac-agent.containers.rbacAgent.resources.limits.memory | string | `"40Mi"` | Memory resource limits. |
| kubernetes-rbac-agent.containers.rbacAgent.resources.requests.memory | string | `"25Mi"` | Memory resource requests. |
| kubernetes-rbac-agent.containers.rbacAgent.tolerations | list | `[]` | Set tolerations |
| kubernetes-rbac-agent.enabled | bool | `true` |  |
| kubernetes-rbac-agent.roleType | string | `"scope"` |  |
| kubernetes-rbac-agent.url.fromConfigMap | string | `"{{ include \"stackstate-k8s-agent.url.configmap.internal.name\" . }}"` |  |
| logsAgent.affinity | object | `{}` | Affinity settings for pod assignment. |
| logsAgent.enabled | bool | `true` | Enable / disable k8s pod log collection |
| logsAgent.image.pullPolicy | string | `"IfNotPresent"` | Default container image pull policy. |
| logsAgent.image.repository | string | `"stackstate/promtail"` | Base container image repository. |
| logsAgent.image.tag | string | `"2.9.15-b617a45b-105"` | Default container image tag. |
| logsAgent.nodeSelector | object | `{}` | Node labels for pod assignment. |
| logsAgent.priorityClassName | string | `""` | Priority class for logsAgent pods. |
| logsAgent.resources.limits.cpu | string | `"1300m"` | CPU resource limits. |
| logsAgent.resources.limits.memory | string | `"192Mi"` | Memory resource limits. |
| logsAgent.resources.requests.cpu | string | `"20m"` | CPU resource requests. |
| logsAgent.resources.requests.memory | string | `"100Mi"` | Memory resource requests. |
| logsAgent.serviceaccount.annotations | object | `{}` | Annotations for the service account for the daemonset pods |
| logsAgent.skipSslValidation | bool | `false` | If true, ignores the server certificate being signed by an unknown authority. |
| logsAgent.tolerations | list | `[]` | Toleration labels for pod assignment. |
| logsAgent.updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":100},"type":"RollingUpdate"}` | The update strategy for the DaemonSet object. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeAgent.affinity | object | `{}` | Affinity settings for pod assignment. |
| nodeAgent.autoScalingEnabled | bool | `false` | Enable / disable autoscaling for the node agent pods. |
| nodeAgent.checksTagCardinality | string | `"orchestrator"` | low, orchestrator or high. Orchestrator level adds pod_name, high adds display_container_name |
| nodeAgent.config | object | `{"override":[]}` |  |
| nodeAgent.config.override | list | `[]` | A list of objects containing three keys `name`, `path` and `data`, specifying filenames at specific paths which need to be (potentially) overridden using a mounted configmap |
| nodeAgent.containerRuntime.customSocketPath | string | `""` | If the container socket path does not match the default for CRI-O, Containerd or Docker, supply a custom socket path. |
| nodeAgent.containerRuntime.hostProc | string | `"/proc"` |  |
| nodeAgent.containers.agent.env | object | `{}` | Additional environment variables for the agent container |
| nodeAgent.containers.agent.image.pullPolicy | string | `"IfNotPresent"` | Default container image pull policy. |
| nodeAgent.containers.agent.image.repository | string | `"stackstate/stackstate-k8s-agent"` | Base container image repository. |
| nodeAgent.containers.agent.image.tag | string | `"b85512ad"` | Default container image tag. |
| nodeAgent.containers.agent.livenessProbe.enabled | bool | `true` | Enable use of livenessProbe check. |
| nodeAgent.containers.agent.livenessProbe.failureThreshold | int | `3` | `failureThreshold` for the liveness probe. |
| nodeAgent.containers.agent.livenessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the liveness probe. |
| nodeAgent.containers.agent.livenessProbe.periodSeconds | int | `15` | `periodSeconds` for the liveness probe. |
| nodeAgent.containers.agent.livenessProbe.successThreshold | int | `1` | `successThreshold` for the liveness probe. |
| nodeAgent.containers.agent.livenessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the liveness probe. |
| nodeAgent.containers.agent.logLevel | string | `nil` | Set logging verbosity, valid log levels are: trace, debug, info, warn, error, critical, and off # If not set, fall back to the value of agent.logLevel. |
| nodeAgent.containers.agent.readinessProbe.enabled | bool | `true` | Enable use of readinessProbe check. |
| nodeAgent.containers.agent.readinessProbe.failureThreshold | int | `3` | `failureThreshold` for the readiness probe. |
| nodeAgent.containers.agent.readinessProbe.initialDelaySeconds | int | `15` | `initialDelaySeconds` for the readiness probe. |
| nodeAgent.containers.agent.readinessProbe.periodSeconds | int | `15` | `periodSeconds` for the readiness probe. |
| nodeAgent.containers.agent.readinessProbe.successThreshold | int | `1` | `successThreshold` for the readiness probe. |
| nodeAgent.containers.agent.readinessProbe.timeoutSeconds | int | `5` | `timeoutSeconds` for the readiness probe. |
| nodeAgent.containers.agent.resources.limits.cpu | string | `"270m"` | CPU resource limits. |
| nodeAgent.containers.agent.resources.limits.memory | string | `"420Mi"` | Memory resource limits. |
| nodeAgent.containers.agent.resources.requests.cpu | string | `"20m"` | CPU resource requests. |
| nodeAgent.containers.agent.resources.requests.memory | string | `"180Mi"` | Memory resource requests. |
| nodeAgent.containers.processAgent.enabled | bool | `true` | Enable / disable the process agent container. |
| nodeAgent.containers.processAgent.env | object | `{}` | Additional environment variables for the process-agent container |
| nodeAgent.containers.processAgent.image.pullPolicy | string | `"IfNotPresent"` | Process-agent container image pull policy. |
| nodeAgent.containers.processAgent.image.registry | string | `nil` |  |
| nodeAgent.containers.processAgent.image.repository | string | `"stackstate/stackstate-k8s-process-agent"` | Process-agent container image repository. |
| nodeAgent.containers.processAgent.image.tag | string | `"19a5b791"` | Default process-agent container image tag. |
| nodeAgent.containers.processAgent.logLevel | string | `nil` | Set logging verbosity, valid log levels are: trace, debug, info, warn, error, critical, and off # If not set, fall back to the value of agent.logLevel. |
| nodeAgent.containers.processAgent.procVolumeReadOnly | bool | `true` | Configure whether /host/proc is read only for the process agent container |
| nodeAgent.containers.processAgent.resources.limits.cpu | string | `"125m"` | CPU resource limits. |
| nodeAgent.containers.processAgent.resources.limits.memory | string | `"400Mi"` | Memory resource limits. |
| nodeAgent.containers.processAgent.resources.requests.cpu | string | `"25m"` | CPU resource requests. |
| nodeAgent.containers.processAgent.resources.requests.memory | string | `"128Mi"` | Memory resource requests. |
| nodeAgent.httpTracing.enabled | bool | `true` | Enable / disable the process-agent HTTP tracing. |
| nodeAgent.logLevel | string | `"INFO"` | Logging level for agent processes. |
| nodeAgent.nodeSelector | object | `{}` | Node labels for pod assignment. |
| nodeAgent.priorityClassName | string | `""` | Priority class for nodeAgent pods. |
| nodeAgent.protocolInspection.enabled | bool | `true` | Enable / disable the nodeAgent protocol inspection. |
| nodeAgent.scaling.autoscalerLimits.agent.maximum.cpu | string | `"200m"` | Maximum CPU resource limits for main agent. |
| nodeAgent.scaling.autoscalerLimits.agent.maximum.memory | string | `"450Mi"` | Maximum memory resource limits for main agent. |
| nodeAgent.scaling.autoscalerLimits.agent.minimum.cpu | string | `"20m"` | Minimum CPU resource limits for main agent. |
| nodeAgent.scaling.autoscalerLimits.agent.minimum.memory | string | `"180Mi"` | Minimum memory resource limits for main agent. |
| nodeAgent.scaling.autoscalerLimits.processAgent.maximum.cpu | string | `"200m"` | Maximum CPU resource limits for process agent. |
| nodeAgent.scaling.autoscalerLimits.processAgent.maximum.memory | string | `"500Mi"` | Maximum memory resource limits for process agent. |
| nodeAgent.scaling.autoscalerLimits.processAgent.minimum.cpu | string | `"25m"` | Minimum CPU resource limits for process agent. |
| nodeAgent.scaling.autoscalerLimits.processAgent.minimum.memory | string | `"100Mi"` | Minimum memory resource limits for process agent. |
| nodeAgent.scc.enabled | bool | `false` | Enable / disable the installation of the SecurityContextConfiguration needed for installation on OpenShift. |
| nodeAgent.service | object | `{"annotations":{},"loadBalancerSourceRanges":["10.0.0.0/8"],"type":"ClusterIP"}` | The Kubernetes service for the agent |
| nodeAgent.service.annotations | object | `{}` | Annotations for the service |
| nodeAgent.service.loadBalancerSourceRanges | list | `["10.0.0.0/8"]` | The IP4 CIDR allowed to reach LoadBalancer for the service. For LoadBalancer type of service only. |
| nodeAgent.service.type | string | `"ClusterIP"` | Type of Kubernetes service: ClusterIP, LoadBalancer, NodePort |
| nodeAgent.serviceaccount.annotations | object | `{}` | Annotations for the service account for the agent daemonset pods |
| nodeAgent.skipKubeletTLSVerify | bool | `false` | Set to true if you want to skip kubelet tls verification. |
| nodeAgent.skipSslValidation | bool | `false` | Set to true if self signed certificates are used. |
| nodeAgent.tolerations | list | `[]` | Toleration labels for pod assignment. |
| nodeAgent.updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":100},"type":"RollingUpdate"}` | The update strategy for the DaemonSet object. |
| nodeAgent.useHostNetwork | bool | `true` | Set to true if you want to deploy the node agent in the host network namespace. |
| nodeAgent.useHostPID | bool | `true` | Set to true if you want to deploy the node agent in the host PID namespace. |
| openShiftLogging.installSecret | bool | `false` | Install a secret for logging on openshift |
| processAgent.checkIntervals.connections | int | `30` | Override the default value of the connections check interval in seconds. |
| processAgent.checkIntervals.process | int | `32` | Override the default value of the process check interval in seconds. |
| processAgent.disabledProtocols | list | `[]` | List of protocols to disable for protocol inspection. Supported protocols are http, http2, mongo, amqp, postgres, tls. If nothing is provided all protocols will be enabled. |
| processAgent.podCorrelation.attributes | list | `[]` | The attributes to be added to all exported metrics. If nothing is provided a default set will be used. |
| processAgent.podCorrelation.enabled | bool | `false` | [Experimental] Enable / disable pod correlation. |
| processAgent.podCorrelation.exporter.endpoint | string | `""` | Override the default endpoint to which the exporter will send metrics (e.g. "otel-collector-service:4317"). |
| processAgent.podCorrelation.exporter.interval | int | `30` | The interval at which the exporter will send metrics (in seconds). |
| processAgent.podCorrelation.exporter.type | string | `""` | The type of the exporter to use for metrics. Possible values ("otlp", "stdout") |
| processAgent.podCorrelation.partialCorrelation | bool | `false` | Enable / disable partial pod correlation. if false the agent will export only pod<->pod metrics. Both extremities of the connection must be pods. |
| processAgent.podCorrelation.protocolMetrics | bool | `false` | Enable / disable exporting protocol metrics. If false the agent will export only metrics for network connections. |
| processAgent.podCorrelation.remoteCache | bool | `false` | When true, the chart will deploy a remote kube cache service and populate the process-agent environment with the service address (serviceName.namespace:grpcPort). Set to `false` to use a local informer inside the process-agent and avoid deploying the remote cache. |
| processAgent.softMemoryLimit.goMemLimit | string | `"340MiB"` | Soft-limit for golang heap allocation, for sanity, must be around 85% of nodeAgent.containers.processAgent.resources.limits.cpu. |
| processAgent.softMemoryLimit.httpObservationsBufferSize | int | `40000` | Sets a maximum for the number of http observations to keep in memory between check runs, to use 40k requires around ~400Mib of memory. |
| processAgent.softMemoryLimit.httpStatsBufferSize | int | `40000` | Sets a maximum for the number of http stats to keep in memory between check runs, to use 40k requires around ~400Mib of memory. |
| remoteKubeCache.affinity | object | `{}` | Affinity settings for pod assignment. |
| remoteKubeCache.nodeSelector | object | `{}` | Node labels for pod assignment. |
| remoteKubeCache.resources.limits.cpu | string | `"200m"` | CPU resource limits. |
| remoteKubeCache.resources.limits.memory | string | `"400Mi"` | Memory resource limits. |
| remoteKubeCache.resources.requests.cpu | string | `"100m"` | CPU resource requests. |
| remoteKubeCache.resources.requests.memory | string | `"200Mi"` | Memory resource requests. |
| remoteKubeCache.tolerations | list | `[]` | Toleration labels for pod assignment. |
| stackstate.apiKey | string | `nil` | **PROVIDE YOUR API KEY HERE** API key to be used by the agent. |
| stackstate.cluster.authToken | string | `""` | Provide a token to enable secure communication between the agent and the cluster agent. |
| stackstate.cluster.name | string | `nil` | **PROVIDE KUBERNETES CLUSTER NAME HERE** Name of the Kubernetes cluster where the agent will be installed. |
| stackstate.customApiKeySecretKey | string | `"sts-api-key"` | Key in the secret containing the receiver API key. |
| stackstate.customClusterAuthTokenSecretKey | string | `"sts-cluster-auth-token"` | Key in the secret containing the cluster auth token. |
| stackstate.customSecretName | string | `""` | Name of the secret containing the receiver API key. |
| stackstate.manageOwnSecrets | bool | `false` | Set to true if you don't want this helm chart to create secrets for you. |
| stackstate.url | string | `nil` | **PROVIDE STACKSTATE URL HERE** URL of the StackState installation to receive data from the agent. |
| targetSystem | string | `"linux"` | Target OS for this deployment (possible values: linux) |
