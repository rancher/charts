# HPE Volume Driver for Kubernetes FlexVolume Plugin Helm chart
The [HPE Volume Driver for Kubernetes FlexVolume Plugin](https://github.com/hpe-storage/flexvolume-driver) leverages HPE storage platforms to provide scalable and persistent storage for stateful applications. This chart also deploys the [HPE Dynamic Provisioner for Kubernetes](https://github.com/hpe-storage/k8s-dynamic-provisioner).

## Prerequisites

- Upstream Kubernetes version 1.11 or later
- Other Kubernetes distributions supported
- Rancher 2.x
- OpenShift 3.10, 3.11 (4.x will not be supported, see [CSI Driver Helm chart](https://github.com/hpe-storage/co-deployments/tree/master/helm/charts/hpe-csi-driver))
- More distributions will be listed as tests are ongoing
- Recent Ubuntu, CentOS or RHEL compute nodes connected to their respective official package repositories

Depending on which `pluginType` is being used, other prerequisites and requirements may apply.

### HPE Nimble Storage (nimble)

- NimbleOS 5.0.8 or later
- NimbleOS 5.1.3 or later

### HPE Cloud Volumes

- Amazon EKS 1.12.x/1.13.x
- Microsoft AKS 1.12.x/1.13.x
- US Regions Only

## Configuration & Installation
The following table lists the configurable parameters of the FlexVolume driver chart and their default values.

|  Parameter                |  Description                                                                                       |  Default    |
|---------------------------|----------------------------------------------------------------------------------------------------|------------ |
| backend            | HPE storage platform API endpoint.                                                                   | 192.168.1.1 |
| pluginType         | Backend plugin type to use. Currently `nimble` and `cv` are supported.                                    | nimble      |
| username           | Username for the backend. Access key for HPE Cloud Volumes.                                                                            | admin       |
| password           | Password for the backend. Access secret for HPE Cloud Volumes.                                                                            | admin       |
| protocol           | Data plane protocol (`fc`, `iscsi`).                                                                 | iscsi       |
| fsType             | Type of file to format volumes with (ext4, ext3, xfs, btrfs).                                        | xfs         |
| logLevel             | Log level. Can be one of `info`, `debug`, `trace`, `warn` and `error`                                        | info         |
| mountConflictDelay | Wait this long (in seconds) before forcefully taking over a volume from an isolated or crashed node. | 120         |
| flavor             | Kubernetes distribution specific tweaks. Supported flavors include `k8s`, `ocp`, `eks`, `aks` and `rke`.                      | k8s           |
| podsMountDir       | This is the directory where the kubelet bind mounts the volume for pods. May differ between Kubernetes distributions.          | /var/lib/kubelet/pods     |
| storageClass.name  | The name to assign the created StorageClass.                                          | hpe-standard |
| storageClass.create | Enables creation of StorageClass to consume this hpe-flexvolume-driver instance.                              | true        |
| storageClass.defaultClass | Whether to set the created StorageClass as the clusters default StorageClass.                                | false       |
| nimble.config      | HPE Nimble Storage volume config parameters.                                                                        | -           |
| cv.config      | HPE Cloud Volumes volume config parameters.                                                                             | -           |

It's recommended to create a `values.yaml` file and edit it to fit the environment the chart is being deployed to.

Example `values.yaml` using a Nimble backend:

```
---
backend: 192.168.1.1
username: admin
password: admin
pluginType: nimble
fsType: xfs
storageClass:
  defaultClass: true
```

This will connect the driver to a Nimble based backend with management IP address of `192.168.1.1` and format new volumes with a XFS filesystem.

The `nimble.config` or `cv.config` stanza will be hosted in a `ConfigMap` and can be used to tweak default parmaters and also override `StorageClass` parameters. More information on these stanzas can be found in the [ADVANCED.md](https://github.com/hpe-storage/flexvolume-driver/blob/master/ADVANCED.md) documentation.

Example `nimble.config` stanza:

```
nimble:
  config:
    limitIOPS: "-1"
    limitMBPS: "-1"
    perfPolicy: DockerDefault
```

Example `cv.config` stanza:

```
cv:
  config:
    snapPrefix: BaseFor
    automatedConnection: true
    existingCloudSubnet: 10.1.0.0/24
    region: us-east-1
    privateCloud: vpc-data
    cloudComputeProvider: "Amazon AWS"
    perfPolicy: Other
    volumeType: PF
    encryption: true
    protectionTemplate: twicedaily:4
    destroyOnRm: true
    limitIOPS: "1000"
    initiators:
      - '"eth0"'
    privateCloudResourceGroup: ""
```

**Note:** Storage class parameters will override the settings in `defaults` and `global` section.

### Platform notes
Certain distributions demand certain tweaks to the variables for the driver and dynamic provisioner to operate correctly. See each platform for details.

#### Upstream Kubernetes
This is the default operating mode, no tweaks are needed.

#### Red Hat OpenShift and OKD
Applicable to Red Hat OpenShift 3.10 and 3.11. 4.x is not supported<sup>*</sup>.

| Key        | Value                     | Description                                                                        |
|------------|---------------------------|------------------------------------------------------------------------------------|
| podsMountDir | /var/lib/origin/openshift.local.volumes       | This is the directory where the kubelet bind mounts the volume for pods.            |

<sup>*</sup> = If experimentation is desirable with OpenShift 4.x, set `flexVolumeExec` default path for ocp to `/etc/kubernetes/kubelet-plugins/volume/exec`. The driver will only work on RHEL 7.x nodes.

#### Rancher
Applicable to installing the Helm Chart via the Rancher catalog system.

| Key        | Value                     | Description                                                                        |
|------------|---------------------------|------------------------------------------------------------------------------------|
| flavor     | rke                   | Required and prepopulated by default.                                              |
| podsMountDir | /var/lib/kubelet/volumeplugins       | This is the directory where the kubelet bind mounts the volume for pods. Required and prepopulated by default.|

## Installing the Chart
To install the chart with the name `hpe-flexvolume`:

```
helm repo add hpe-storage https://hpe-storage.github.io/co-deployments/
helm install hpe-storage/hpe-flexvolume-driver --namespace kube-system --name hpe-flexvolume -f values.yaml
```

**Note:** Omitting the `--name` flag will generate a human readable name.

## Check status of the Chart
To check status of the `hpe-flexvolume` deployment:

```
helm status hpe-flexvolume
```

## Uninstalling the Chart
To uninstall/delete the `hpe-flexvolume` deployment:

```
helm delete hpe-flexvolume --purge
```

## Alternative install method
In some cases it's more practical provide the local configuration via the `helm` command directly. Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```
helm install --name hpe-flexvolume hpe/hpe-flexvolume-driver \
--set backend=X.X.X.X --set username=admin --set password=xxxxxxxxx \
--set protocol=iscsi --set fsType=xfs
```

## Using the HPE Volume Driver for Kubernetes FlexVolume Plugin
To enable dynamic provisioning of `PersistentVolume` through the use of `PersistentVolumeClaim` API objects, a `StorageClass` needs to be declared on the cluster. Please see the [HPE Volume Driver for Kubernetes FlexVolume Plugin](https://github.com/hpe-storage/flexvolume-driver) repository for the official documentation for this Helm chart. Also, it's helpful to be familar with [persistent storage concepts](https://kubernetes.io/docs/concepts/storage/volumes/) in Kubernetes prior to deploying stateful workloads.

## Support
The HPE Volume Driver for Kubernetes FlexVolume Plugin Helm chart is supported by the respective platform team. Currently supported platforms:

- HPE Nimble Storage
- HPE Cloud Volumes

Please file issues through the regular support channels for the particular platform. Feature requests or general questions to developers may be filed through the [GitHub issue tracker](https://github.com/hpe-storage/co-deployments) for this project.

You may also join our Slack community to chat with HPE folks close to this project for inquiries not requring our immediate response. We hang out in `#NimbleStorage` and `#Kubernetes` at [slack.hpedev.io](https://slack.hpedev.io/).

## Contributing
We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [CONTRIBUTING.md](https://github.com/hpe-storage/co-deployments/blob/master/CONTRIBUTING.md)

## License
This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/hpe-storage/co-deployments/blob/master/LICENSE) for details.
