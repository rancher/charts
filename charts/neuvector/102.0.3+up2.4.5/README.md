# NeuVector Helm Chart

## Deployment & Operation Practices

+ For the latest *Onboarding and Best Practices Guide* click [**HERE**](https://open-docs.neuvector.com/deploying/production/NV_Onboarding_5.0.pdf)
+ For instructions to deploy NeuVector in an airgap environment, click [**HERE**](https://open-docs.neuvector.com/deploying/airgap)
+ NeuVector API reference can be found [**HERE**](https://raw.githubusercontent.com/neuvector/neuvector/main/controller/api/apis.yaml); and basic usage examples [**HERE**](https://open-docs.neuvector.com/automation/automation).

## Configuration

The following tables list the most common configurable parameters of the NeuVector chart and their default values.

## General Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`controller.image.pullPolicy` | Image pull policy | `Always` | Options are: `Always`, `IfNotPresent`, or `Never` |
`enforcer.image.pullPolicy` | Image pull policy | `Always` | Options are: `Always`, `IfNotPresent`, or `Never` |
`manager.image.pullPolicy` | Image pull policy | `Always` | Options are: `Always`, `IfNotPresent`, or `Never` |
`monitoring.exporter.image.pullPolicy` | Image pull policy | `Always` | Options are: `Always`, `IfNotPresent`, or `Never` |
`registry` | NeuVector container registry | `docker.io` |
`oem` | OEM release name | `nil` |
`rbac` | NeuVector RBAC manifests are installed when enabled | `true` |
`psp` | NeuVector Pod Security Policy will be configured when enabled | `false` | For Kubernetes v1.25+ this value must remain `false` |
`rancherSSO.enabled` | If true, enable Rancher single sign on | `true` | Rancher server address will be auto-configured if set to `true` |
`serviceAccount` | Service account name for NeuVector components | `neuvector` |

> **NOTE** :pencil2:
> The below values are also configurable as UI elements when installing via Rancher Apps.

## Container Runtime Setting

The NeuVector platform supports `bottlerocket`, `containerd`, `cri-o`, `docker`, `k3s`, or `rke2` as the container runtime.  **==This selection is mandatory!==**

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`systemSettings.containerRuntime` | Set to the container runtime of target cluster | `nil` | Options are `bottlerocket`, `containerd`, `crio`, `docker`, `k3s`, or `rke2` |

## System Configuration Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`controller.image.tag` | Image tag for Controller Deployment | `5.1.2` |
`enforcer.image.tag` | Image tag for Enforcer Daemonset | `5.1.2` |
`manager.image.tag` | Image tag for Manager Deployment | `5.1.2` |
`systemSettings.telemetryOptOut` | Sends anonymous NeuVector telemetry data | `false` | Collects number of: nodes, container groups, and admission control rules
`systemSettings.createLocalAdmin` | Create default local 'admin' account | `true` | This option can also be used to change an existing admin password |
`controller.pvc.enabled` | Enable persistence for Controller using PVC | `false` | Requires persistent volume type `Read Write Many (RWX)`, and capacity of 1Gi |
`controller.pvc.storageClass` | StorageClass that PVC will use | `nil` | Will use cluster's default StorageClass if none is specified |
`systemSettings.zeroDrift` | Enable (zero-drift) or disable (basic) automated protection that prevents processes and file system drift for new groups. | `zero-drift` | Options are `basic` or `zero-drift` |

## Scanner Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`platformInfo` | If set, enables GKE-specific CIS Benchmark Scans | `nil` | Only current option is `Kubernetes:GKE` |
`systemSettings.autoScan` | Enables auto-scanning of discovered assets | `false` |
`systemSettings.scannerAutoscale.customize` | Customize behavior of Scanner Autoscaler | `false` |
`systemSettings.scannerAutoscale.maxPods` | Maximum count for Scanner Pods | `3` |
`systemSettings.scannerAutoscale.minPods` | Minimum count for Scanner Pods | `1` |
`systemSettings.scannerAutoscale.scalingStrategy` | Scanner sclaing strategy | `delayed` |

## Pod Scheduling Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`controller.replicas` | Configure number of replicas for Controller Deployment | `3`| Controller replica count must be odd-numbered value for proper HA (Raft consensus) |
`controller.tolerateControlPlane` | Allow Controller replicas to be scheduled on Kubernetes Control Plane nodes | `true` |
`enforcer.tolerateControlPlane` | Allow Enforcer replicas to be scheduled on Kubernetes Control Plane nodes | `true` |

## Monitoring Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`monitoring.enabled` | Enable & configure Prometheus Service Monitoring and Grafana Dashboard | `false` | Prometheus & Grafana deployment must already exist |
`monitoring.exporter.credentials` | **Read-only** metrics scraping account | `Fullname: monitoring`<br>`Password: Pr0m3th3u$` |
`monitoring.exporter.grafanaDashboard.namespace` | Namespace for Grafana dashboard ConfigMap | `nil` | Set to `cattle-dashboards` if using Rancher monitoring chart |
`monitoring.exporter.grafanaDashboard.scrapeEnforcerMetrics` | Scrape metrics of Enforcer Pods | `false` | Defaults to `false` for performance reasons |

## Container Registry Proxy

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`systemSettings.registryProxy.http.enabled` | For enabling and configuring HTTP proxy settings to external image registries | `false` |
`systemSettings.registryProxy.http.httpProxy.url` | URL to proxy server | `nil` |
`systemSettings.registryProxy.http.httpProxy.username` | Username for proxy server | `nil` | Optional value |
`systemSettings.registryProxy.http.httpProxy.password` | Password for proxy server | `nil` | Optional value |
`systemSettings.registryProxy.https.enabled` | For enabling and configuring HTTPS proxy settings to external image registries | `false` |
`systemSettings.registryProxy.https.httpsProxy.url` | URL to proxy server | `nil` |
`systemSettings.registryProxy.https.httpsProxy.username` | Username for proxy server | `nil` | Optional value |
`systemSettings.registryProxy.https.httpsProxy.password` | Password for proxy server | `nil` | Optional value |

## Syslog Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`systemSettings.syslog.enabled` | Enable and configure Syslog server settings | `false` |
`systemSettings.syslog.jsonOutput` | Output logs in JSON format | `nil` |
`systemSettings.syslog.logLevel` | Log level for Syslog events | `Info` | Options are: `Alert`, `Critical`, `Error`, `Info`, `Warning`, `Notice`, or `Debug` |
`systemSettings.syslog.protocol` | Listening protocol for Syslog server | `udp` | Options are: `tcp` or `udp` |
`systemSettings.syslog.serverIP` | IP address or FQDN for Syslog server | `nil` |

## External Authentication Settings

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----|
`externalAuthProvider.enabled` | Enable & configure external provider for NeuVector authentication | `false` |
`externalAuthProvider.provider` | Authentication provider NeuVector will use | `nil` | Options are: `ldap`, `oidc`, or `saml` |
`externalAuthProvider.provider.config` | YAML formatted provider config | `nil` |

## Troubleshooting

For basic troubleshooting guidance, consult the [*Troubleshooting section*](https://open-docs.neuvector.com/troubleshooting/troubleshooting) of our site.
