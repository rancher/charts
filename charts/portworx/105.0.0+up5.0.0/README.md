# Portworx

[Portworx](https://portworx.com/) is a software defined persistent storage solution designed and purpose built for applications deployed as containers, via container orchestrators such as Kubernetes, Marathon and Swarm. It is a clustered block storage solution and provides a Cloud-Native layer from which containerized stateful applications programmatically consume block, file and object storage services directly through the scheduler.

## Pre-requisites
The helm chart (portworx-helm) deploys Portworx and Stork (https://docs.portworx.com/scheduler/kubernetes/stork.html) on your Kubernetes cluster. The minimum requirements for deploying the helm chart are as follows:

- Helm has been installed on the client machine from where you would install the chart (https://docs.helm.sh/using_helm/#installing-helm).
- Tiller version 2.9.0 and above is running on the Kubernetes cluster where you wish to deploy Portworx.
- Tiller has been provided with the right RBAC permissions for the chart to be deployed correctly.
- Kubernetes 1.7+
- All [pre-requisites](https://docs.portworx.com/install-portworx/prerequisites/) for Portworx fulfilled.

## Upgrading the Chart from an old chart with Daemonset
1. Deploy StorageCluster CRD. 
Helm does not handle CRD upgrade, let's manually deploy it.
```
kubectl apply -f ./charts/portworx/crds/core_v1_storagecluster_crd.yaml
```
2. Run helm upgrade with the original values.yaml that was used to deploy the Daemonset chart.
```
helm upgrade [RELEASE] [CHART] -f values.yaml
```
3. Review the StorageCluster spec. If any value is not expected, change values.yaml and run `helm upgrade` to update it.
```
kubectl -n kube-system describe storagecluster
```
4. Approve the migration
```
kubectl -n kube-system annotate storagecluster --all --overwrite portworx.io/migration-approved='true'
```
5. Wait for migration to complete
Describe the StorageCluster to see event `Migration completed successfully`. If migration fails, there is corresponding event about the failure.
```
kubectl -n kube-system describe storagecluster
```
6. Rollback to Daemonset (Unsupported)

Use `helm rollback` to rollback to Daemonset install is not supported, if there is any issue during migration please try to update values.yaml and perform `helm upgrade`. 

## Installing the Chart

To install the chart with the release name `my-release` run the following commands substituting relevant values for your setup:

##### NOTE:
Upgrading from previous versions to 4.0.0 is not backward compatible. Please review the values configuration for the latest release.

`internalKVDB` is set to `true` by default. Portworx would by default use internal kvdb.

To use an external KVDB, you can provide the `etcdEndPoint`
If the etcd cluster being used is a secured etcd (SSL/TLS) then please follow instructions to create a kubernetes secret with the certs. https://docs.portworx.com/scheduler/kubernetes/etcd-certs-using-secrets.html#create-kubernetes-secret


`clusterName` should be a unique name identifying your Portworx cluster. The default value is `mycluster`, but it is suggested to update it with your naming scheme.

For eg:
```
git clone https://github.com/portworx/helm.git
helm install --debug --name my-release --set clusterName=$(uuidgen) ./helm/charts/portworx/
```

## Configuration

The following tables lists the configurable parameters of the Portworx chart and their default values.

| Parameter | Description | Default
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| `imageVersion` | Version of the PX image | 3.1.4 |
| `pxOperatorImageVersion` | Version of the PX operator image | 24.1.1 |
| `openshiftInstall` | Installing on Openshift? | false |
| `pksInstall` | Installing on Pivotal Container service? | false |
| `EKSInstall` | Installing EKS (Amazon Elastic Container service) | false |
| `AKSInstall` | Installing on AKS (Azure Kubernetes service) | false |
| `GKEInstall` | Installing on GKE (Google Kubernetes Engine) | false |
| `etcdEndPoint` | (REQUIRED) etcd endpoint for PX to function properly in the form "etcd:http://<your-etcd-endpoint>". Multiple Urls should be semi-colon seperated example: etcd:http://<your-etcd-endpoint1>;etcd:http://<your-etcd-endpoint2> | "" |
| `clusterName` | Portworx Cluster Name | "mycluster" |
| `usefileSystemDrive` | Should Portworx use an unmounted drive even with a filesystem ? | false |
| `usedrivesAndPartitions` | Should Portworx use the drives as well as partitions on the disk ? | false |
| `drives` | Semi-colon seperated list of drives to be used for storage (example: "/dev/sda;/dev/sdb") | "none" |
| `provider` | Specifies the cloud provider name, such as: pure, azure, aws, gce, vsphere, if using cloud storage. | "" |
| `journalDevice` | Journal device for Portworx metadata | "" |
| `cacheDevices` | semi-colon seperated list of cache devices Portworx should use. | "" |
| `maxStorageNodesPerZone` | Indicates the maximum number of storage nodes per zone. If this number is reached, and a new node is added to the zone, Portworx doesn't provision drives for the new node. Instead, Portworx starts the node as a compute-only node | 0 |
| `maxStorageNodes` | Specifies the maximum number of storage nodes. If this number is reached, and a new node is added, Portworx doesn't provision drives for the new node. Instead, Portworx starts the node as a compute-only node. As a best practice, it is recommended to use the `maxStorageNodesPerZone` field | 0 |
| `systemMetadataDevice` | Specifies the device Portworx uses to store metadata. | "" |
| `secretType` | Secrets store to be used can be AWS KMS/KVDB/Vault/K8s/IBM Key Protect | k8s |
| `dataInterface` | Name of the interface <ethX> | "none" |
| `managementInterface` | Name of the interface <ethX> | "none" |
| `serviceType` | Kubernetes service type for services deployed by the Operator. Direct Values like 'LoadBalancer', 'NodePort' will change all services. To change the types of specific services, value can be specified as 'portworx-service:LoadBalancer;portworx-api:ClusterIP'| "none" |
| `runtimeOptions` | semi-colon seperated list of key-value pairs that overwrite the runtime options.| "" |
| `featureGates` | semi-colon seperated list of key-value specifying which Portworx features should be enabled or disabled | "" |
| `security.enabled` | Enables or disables Security at any given time | false |
| `security.auth.guestAccess` | Determines how the guest role will be updated in your cluster. Options are Enabled, Disabled, or Managed | "Enabled" |
| `security.auth.selfSigned.tokenLifetime` | Time till operator-generated tokens will be alive until being refreshed | "" |
| `security.auth.selfSigned.issuer` | The issuer name to be used when configuring PX-Security | "" |
| `security.auth.selfSigned.sharedSecret` | The Kubernetes secret name for retrieving and storing your shared secret. | "" |
| `resources` | Configure Portworx container usage such as memory and CPU usage.| {} |
| `customMetadata.annotations.pod.storage` | Custom annotations for Portworx pods | "" |
| `customMetadata.annotations.service.portworxApi` | Custom annotations for portwork-api service | "" |
| `customMetadata.annotations.service.portworxService` | Custom annotations for portwork-service | "" |
| `customMetadata.annotations.service.portworxKVDBService` | Custom annotations for portworx-kvdb-service | "" |
| `customMetadata.labels.service.portworxApi` | Custom labels for portwork-api service. Currently, custom labels are only supported on the portworx-api service | "" |
| `envVars` | semi-colon-separated list of environment variables that will be exported to portworx. (example: MYENV1=val1;MYENV2=val2) ( Depricated : use `envs` to set environment variables) | "none" |
| `envs` | Add environment variables to the Portworx container in all Kubernetes-supported formats | [] |
| `disableStorageClass` | Disable installation of default Portworx StorageClasses. | false |
| `stork.enabled` | [Storage Orchestration for Hyperconvergence](https://github.com/libopenstorage/stork). | true |
| `stork.storkVersion` | The version of stork | "" |
| `stork.args` | Pass arguments to Stork container | "" |
| `stork.volumes` | Add volumes to Stork container | [] |
| `stork.env` | List of Kubernetes like environment variables passed to Stork | [] |
| `customRegistryURL` | Custom Docker registry | "" |
| `registrySecret` | Registry secret | "" |
| `monitoring.prometheus.enabled` | Enable or disable Prometheus | false |
| `monitoring.prometheus.exportMetrics` | Expose the Portworx metrics to an external or operator deployed Prometheus | false |
| `monitoring.prometheus.alertManager` | Enable or disable alertmanager | false |
| `monitoring.prometheus.resources` | Configure stork container resources such memory and cpu | {} |
| `monitoring.prometheus.replicas` | Number of prometheus replicas that will be deployed | 1 |
| `monitoring.prometheus.retention` | Time period for which prometheus retains historical matrics | "24h" |
| `monitoring.prometheus.retentionSize` | Maximum amount of disk space that Prometheus can use to store historical metrics. Example: "10GiB","50MiB" | "" |
| `monitoring.prometheus.storage` | Storage type that Prometheus will use for storing data | {} |
| `monitoring.prometheus.volumes` | Additional volumes for the prometheus statefulSet | [] |
| `monitoring.prometheus.volumeMounts` | Additional VolumeMounts for the Prometheus StatefulSet | [] |
| `monitoring.prometheus.securityContext.runAsNonRoot` | Enable prometheus container run as a non-root user | false |
| `monitoring.telemetry` | Enable or disable telemetry | true |
| `monitoring.grafana` | Enable or disable grafana | false |
| `csi.enabled` | Enables CSI | true |
| `csi.topology.enabled` | Enable CSI topology feature gate | false |
| `csi.installSnapshotController` | Install CSI Snapshot Controller | false |
| `autopilot.enabled` | Enable AutoPilot | true |
| `autopilot.image` | Specify AutoPilot image | "" |
| `autopilot.lockImage` | Enables locking AutoPilot to the given image | false |
| `autopilot.args` | semicolon sperated list to Override or add new AutoPilot arguments | "" |
| `autopilot.env` | List of Kubernetes like environment variables passed to Autopilot | [] |
| `internalKVDB` | Internal KVDB store | true |
| `kvdbDevice` | specify a separate device to store KVDB data, only used when internalKVDB is set to true | "" |
| `kvdb.authSecretName` | Name of the secret for configuring secure KVDB (https://docs.portworx.com/portworx-enterprise/operations/kvdb-for-portworx/external-kvdb#secure-your-etcd-communication)| "none" |
| `etcd.credentials` | Username and password for etcd authentication in the form user:password (Depricated : use `kvdb.authSecretName`) | "none":"none" |
| `etcd.certPath` | Base path where the certificates are placed. (example: if the certificates ca,.crt and the .key are in /etc/pwx/etcdcerts the value should be provided as /etc/pwx/etcdcerts Refer: https://docs.portworx.com/scheduler/kubernetes/etcd-certs-using-secrets.html) (Depricated : use `kvdb.authSecretName`) | "none" |
| `etcd.ca` | Location of CA file for etcd authentication. Should be /path/to/server.ca (Depricated : use `kvdb.authSecretName`)| "none" |
| `etcd.cert` | Location of certificate for etcd authentication. Should be /path/to/server.crt (Depricated : use `kvdb.authSecretName`) | "none" |
| `etcd.key` | Location of certificate key for etcd authentication Should be /path/to/servery.key (Depricated : use `kvdb.authSecretName`)| "none" |
| `consul.token` | ACL token value used for Consul authentication. (example: 398073a8-5091-4d9c-871a-bbbeb030d1f6) (Depricated : use `kvdb.authSecretName`) (Depricated : use `kvdb.authSecretName`) |
| `volumes` | Specifies volumes for Portworx by defining a name, mount path, mount propagation (None, HostToContainer, Bidirectional), and whether the volume is read-only. For secrets, provide the secret name and map specific keys to paths. Supported volume types include Host, Secret, and ConfigMap | [] |
| `tolerations` | Specifies tolerations for scheduling Portworx pods. | [] |
| `nodeAffinity` | Specifies node affinity rules for Portworx pods. | {} |
| `nodesConfiguration` | Override certain cluster-level configurations for individual or groups of nodes, including network, storage, environment variables, and runtime options. | [] |
| `clusterToken.create` | Determines whether a cluster token should be created. | false |
| `clusterToken.secretName` | Name of the Kubernetes secret to be created for the cluster token. Requires clusterToken.create to be true. | "px-vol-encryption" |
| `clusterToken.serviceAccountName` | Service account name to use for the post-install hook to create the cluster token. | "px-create-cluster-token" |
| `deleteStrategy.type` | Optional: Specifies the delete strategy for the Portworx cluster. Valid values: Uninstall, UninstallAndWipe | "" |
| `updateStrategy.type` | Specifies the update strategy for the Portworx cluster. Supported values: RollingUpdate, OnDelete | "" |
| `updateStrategy.maxUnavailable` | Maximum number of nodes that can be unavailable during a rolling update | 1 |
| `updateStrategy.minReadySeconds` | Minimum number of seconds that a pod should be ready before the next batch of pods is updated during a rolling update | 1 |
| `updateStrategy.autoUpdateComponents` | Specifies the update strategy for the component images. Valid values: None, Once, Always | None |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

## Cloud installs

#### Installing on AKS 

Details are [here](https://docs.portworx.com/portworx-install-with-kubernetes/cloud/azure/aks/2-deploy-px/).

> **Tip**: In this case the chart is located at `./helm/charts/portworx`, do change it as per your setup.
```
helm install --name my-release --set imageVersion=1.2.12.0,etcdEndPoint=etcd:http://192.168.70.90:2379 ./helm/charts/portworx/
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,
```
helm install --name my-release -f ./helm/charts/portworx/values.yaml ./helm/charts/portworx
```
> **Tip**: You can use the default [values.yaml](values.yaml) and make changes as per your requirement

#### Installing on IKS [ IBM Cloud ] 

Refer the IBM charts [here](https://github.com/IBM/charts/tree/master/community/portworx)

> **Tip**: You will need to add the IBM charts repo with the repo path set to rawgithub
```
helm repo add ibm-porx https://raw.githubusercontent.com/IBM/charts/master/repo/community
```

## Upgrading Portworx Install

You can update the `imageVersion` value in the YAML file that specifies the values for the parameters used while installing the chart.
```
helm upgrade my-release -f ./helm/charts/portworx/values.yaml ./helm/charts/portworx
```

Alternatively, you can also use the `--set` directive to do the same. For example,
```
helm upgrade my-release --set imageVersion=<px-version>,etcdEndPoint=<list-of-etcd-endpoints>,clusterName=<cluster-name> -f ./helm/charts/portworx/values.yaml  ./helm/charts/portworx 
```

> **Tip**: You can check the upgrade with the new values took effect using. Check the reference for upgrade [here](https://v2.helm.sh/docs/using_helm/#helm-upgrade-and-helm-rollback-upgrading-a-release-and-recovering-on-failure)
```
helm get values my-release
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:
The chart would follow the process as outlined here. (https://docs.portworx.com/scheduler/kubernetes/install.html#uninstall)

> **Tip** > The Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

```
helm delete my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

### Basic troubleshooting

#### Helm install errors with `no available release name found`

```
helm install --dry-run --debug --set etcdEndPoint=etcd:http://192.168.70.90:2379,clusterName=$(uuidgen) ./helm/charts/portworx/
[debug] Created tunnel using local port: '37304'
[debug] SERVER: "127.0.0.1:37304"
[debug] Original chart version: ""
[debug] CHART PATH: /root/helm/charts/portworx

Error: no available release name found
```
This most likely indicates that Tiller doesn't have the right RBAC permissions.
You can verify the tiller logs
```
[storage/driver] 2018/02/07 06:00:13 get: failed to get "singing-bison.v1": configmaps "singing-bison.v1" is forbidden: User "system:serviceaccount:kube-system:default" cannot get configmaps in the namespace "kube-system"
[tiller] 2018/02/07 06:00:13 info: generated name singing-bison is taken. Searching again.
[tiller] 2018/02/07 06:00:13 warning: No available release names found after 5 tries
[tiller] 2018/02/07 06:00:13 failed install prepare step: no available release name found
```



