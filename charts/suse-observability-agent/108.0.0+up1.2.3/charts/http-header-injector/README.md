# http-header-injector

![Version: 0.0.16](https://img.shields.io/badge/Version-0.0.16-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

Helm chart for deploying the http-header-injector sidecar, which automatically injects x-request-id into http traffic
going through the cluster for pods which have the annotation `http-header-injector.stackstate.io/inject: enabled` is set.

**Homepage:** <https://github.com/StackVista/http-header-injector>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Stackstate Lupulus Team | <ops@stackstate.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| certificatePrehook | object | `{"image":{"pullPolicy":"IfNotPresent","registry":null,"repository":"stackstate/container-tools","tag":"1.6.0"},"resources":{"limits":{"cpu":"100m","memory":"200Mi"},"requests":{"cpu":"100m","memory":"200Mi"}}}` | Helm prehook to setup/remove a certificate for the sidecarInjector mutationwebhook |
| certificatePrehook.image.pullPolicy | string | `"IfNotPresent"` | Policy when pulling an image |
| certificatePrehook.image.registry | string | `nil` | Registry for the docker image. |
| certificatePrehook.image.tag | string | `"1.6.0"` | The tag for the docker image |
| debug | bool | `false` | Enable debugging. This will leave leave artifacts around like the prehook jobs for further inspection |
| global.extraAnnotations | object | `{}` | Extra annotations added ta all resources created by the helm chart |
| global.extraLabels | object | `{}` | Extra labels added ta all resources created by the helm chart |
| global.imagePullCredentials | object | `{}` | Globally define credentials for pulling images. |
| global.imagePullSecrets | list | `[]` | Globally add image pull secrets that are used. |
| global.imageRegistry | string | `nil` | Globally override the image registry that is used. Can be overridden by specific containers. Defaults to quay.io |
| images.pullSecretName | string | `nil` |  |
| proxy | object | `{"image":{"pullPolicy":"IfNotPresent","registry":null,"repository":"stackstate/http-header-injector-proxy","tag":"sha-5ff79451"},"resources":{"limits":{"memory":"40Mi"},"requests":{"memory":"25Mi"}}}` | Proxy being injected into pods for rewriting http headers |
| proxy.image.pullPolicy | string | `"IfNotPresent"` | Policy when pulling an image |
| proxy.image.registry | string | `nil` | Registry for the docker image. |
| proxy.image.tag | string | `"sha-5ff79451"` | The tag for the docker image |
| proxy.resources.limits.memory | string | `"40Mi"` | Memory resource limits. |
| proxy.resources.requests.memory | string | `"25Mi"` | Memory resource requests. |
| proxyInit | object | `{"image":{"pullPolicy":"IfNotPresent","registry":null,"repository":"stackstate/http-header-injector-proxy-init","tag":"sha-5ff79451"}}` | InitContainer within pod which redirects traffic to the proxy container. |
| proxyInit.image.pullPolicy | string | `"IfNotPresent"` | Policy when pulling an image |
| proxyInit.image.registry | string | `nil` | Registry for the docker image |
| proxyInit.image.tag | string | `"sha-5ff79451"` | The tag for the docker image |
| sidecarInjector | object | `{"image":{"pullPolicy":"IfNotPresent","registry":null,"repository":"stackstate/generic-sidecar-injector","tag":"sha-5678567f"}}` | Service for injecting the proxy sidecar into pods |
| sidecarInjector.image.pullPolicy | string | `"IfNotPresent"` | Policy when pulling an image |
| sidecarInjector.image.registry | string | `nil` | Registry for the docker image. |
| sidecarInjector.image.tag | string | `"sha-5678567f"` | The tag for the docker image |
| webhook | object | `{"failurePolicy":"Ignore","tls":{"certManager":{"issuer":"","issuerKind":"ClusterIssuer","issuerNamespace":""},"mode":"generated","provided":{"caBundle":"","crt":"","key":""},"secret":{"name":""}}}` | MutationWebhook that will be installed to inject a sidecar into pods |
| webhook.failurePolicy | string | `"Ignore"` | How should the webhook fail? Best is to use Ignore, because there is a brief moment at initialization when the hook s there but the service not. Also, putting this to fail can cause the control plane be unresponsive. |
| webhook.tls.certManager.issuer | string | `""` | The issuer that is used for the webhook. Only used if you set webhook.tls.mode to "cert-manager". |
| webhook.tls.certManager.issuerKind | string | `"ClusterIssuer"` | The issuer kind that is used for the webhook, valid values are "Issuer" or "ClusterIssuer". Only used if you set webhook.tls.mode to "cert-manager". |
| webhook.tls.certManager.issuerNamespace | string | `""` | The namespace the cert-manager issuer is located in. If left empty defaults to the release's namespace that is used for the webhook. Only used if you set webhook.tls.mode to "cert-manager". |
| webhook.tls.mode | string | `"generated"` | The mode for the webhook. Can be "provided", "generated", "secret" or "cert-manager". If you want to use cert-manager, you need to install it first. NOTE: If you choose "generated", additional privileges are required to create the certificate and webhook at runtime. |
| webhook.tls.provided.caBundle | string | `""` | The caBundle that is used for the webhook. This is the certificate that is used to sign the webhook. Only used if you set webhook.tls.mode to "provided". |
| webhook.tls.provided.crt | string | `""` | The certificate that is used for the webhook. Only used if you set webhook.tls.mode to "provided". |
| webhook.tls.provided.key | string | `""` | The key that is used for the webhook. Only used if you set webhook.tls.mode to "provided". |
| webhook.tls.secret.name | string | `""` | The name of the secret containing the pre-provisioned certificate data that is used for the webhook. Only used if you set webhook.tls.mode to "secret". |

