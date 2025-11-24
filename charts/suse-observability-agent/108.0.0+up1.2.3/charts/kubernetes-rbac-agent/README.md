# kubernetes-rbac-agent

![Version: 0.0.20](https://img.shields.io/badge/Version-0.0.20-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

Helm chart for deploying the kubernetes-rbac-agent, which pick up (cluster)role(bindings) from a k8s cluster and forwards them
to the SUSE Observability platform

**Homepage:** <https://github.com/StackVista/kubernetes-rbac-agent>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Suse Observability Lupulus Team | <ops@stackstate.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiKey | string | `nil` | Directly set the api key to use. Can be templated |
| clusterName.fromConfigMap | string | `nil` |  |
| clusterName.value | string | `nil` | Directly set the clusterName |
| containers.rbacAgent.affinity | object | `{}` | Set affinity |
| containers.rbacAgent.env | object | `{}` | Additional environment variables |
| containers.rbacAgent.image.pullPolicy | string | `"IfNotPresent"` | Policy when pulling an image |
| containers.rbacAgent.image.registry | string | `nil` | Registry for the docker image. |
| containers.rbacAgent.image.repository | string | `"stackstate/kubernetes-rbac-agent"` |  |
| containers.rbacAgent.image.tag | string | `"35ec5206"` | The tag for the docker image |
| containers.rbacAgent.nodeSelector | object | `{}` | Set a nodeSelector |
| containers.rbacAgent.podAnnotations | object | `{}` | Additional annotations on the pod |
| containers.rbacAgent.podLabels | object | `{}` | Additional labels on the pod |
| containers.rbacAgent.priorityClassName | string | `""` | Set priorityClassName |
| containers.rbacAgent.resources.limits.memory | string | `"40Mi"` | Memory resource limits. |
| containers.rbacAgent.resources.requests.memory | string | `"25Mi"` | Memory resource requests. |
| containers.rbacAgent.securityContext.enabled | bool | `true` | Whether or not to enable the securityContext |
| containers.rbacAgent.securityContext.fsGroup | int | `65534` | The GID (group ID) of all files on all mounted volumes |
| containers.rbacAgent.securityContext.runAsGroup | int | `65534` | The GID (group ID) of the owning user of the process |
| containers.rbacAgent.securityContext.runAsNonRoot | bool | `true` | Ensure that the user is not root (!= 0) |
| containers.rbacAgent.securityContext.runAsUser | int | `65534` | The UID (user ID) of the owning user of the process |
| containers.rbacAgent.tolerations | list | `[]` | Set tolerations |
| global.apiKey.fromSecret | string | `nil` | The secret from which the receiver api key is taken. Will execute as a template. Overriding this will allow setting the api key from an externally provided secret. |
| global.commonAnnotations | object | `{}` | Common annotations added to all resources created by the helm chart |
| global.commonLabels | object | `{}` | Common labels added to all resources created by the helm chart |
| global.customCertificates | object | `{"configMapName":"","enabled":false,"pemData":""}` | Custom certificates for HTTPS endpoints |
| global.customCertificates.configMapName | string | `""` | Name of existing ConfigMap containing certificates (exclusive with pemData) |
| global.customCertificates.enabled | bool | `false` | Enable custom certificate injection |
| global.customCertificates.pemData | string | `""` | PEM-encoded certificate data (exclusive with configMapName), will be stored as tls.pem |
| global.extraAnnotations | object | `{}` | Extra annotations added ta all resources created by the helm chart (DEPRECATED: use commonAnnotations instead) |
| global.extraLabels | object | `{}` | Extra labels added ta all resources created by the helm chart (DEPRECATED: use commonLabels instead) |
| global.imagePullCredentials | object | `{}` | Globally define credentials for pulling images. |
| global.imagePullSecrets | list | `[]` | Globally add image pull secrets that are used. |
| global.imageRegistry | string | `nil` | Globally override the image registry that is used. Can be overridden by specific containers. Defaults to quay.io |
| global.proxy.url | string | `""` | Proxy for all traffic to stackstate |
| global.skipSslValidation | bool | `false` | Enable tls validation from client |
| roleType | string | `"instance"` | This agent collects two types of (cluster)role(bindings), instance and scope role bindings. Configured through this setting |
| url.fromConfigMap | string | `nil` | Set the cluster name through a config map. Needs to contain 'STS_CLUSTER_NAME' |
| url.value | string | `nil` | Directly set the url value to use. Can be templated |

