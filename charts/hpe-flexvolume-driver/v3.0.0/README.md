# HPE FlexVolume Driver for Kubernetes Helm chart
The [HPE FlexVolume Driver for Kubernetes](https://github.com/hpe-storage/flexvolume-driver) leverages HPE storage platforms to provide scalable and persistent storage for stateful applications. This chart also deploys the [HPE Dynamic Provisioner for Kubernetes](https://github.com/hpe-storage/k8s-dynamic-provisioner).

## Prerequisites

- Upstream Kubernetes version > 1.10
- Other Kubernetes distributions supported
- OpenShift 3.10, 3.11 (4.x will not be supported, see [CSI Driver Helm chart](https://github.com/hpe-storage/co-deployments/tree/master/helm/charts/hpe-csi-driver)
- More distributions will be listed as tests are ongoing
- Recent Ubuntu, CentOS or RHEL compute nodes connected to their respective official package repositories

Depending on which `pluginType` is being used, other prerequisites and requirements may apply.

### HPE Nimble Storage (nimble)

- NimbleOS 5.0.8 or later
- NimbleOS 5.1.3 or later

## Configuration & Installation
The following table lists the configurable parameters of the HPE FlexVolume Driver chart and their default values.

|  Parameter                |  Description                                                                                       |  Default    |
|---------------------------|----------------------------------------------------------------------------------------------------|------------ |
| backend            | HPE storage platform API endpoint.                                                                   | 192.168.1.1 |
| pluginType         | Backend plugin type to use. Currently only `nimble` is supported.                                    | nimble      |
| username           | Username for the backend.                                                                            | admin       |
| password           | Password for the backend.                                                                            | admin       |
| protocol           | Data plane protocol (`fc`, `iscsi`).                                                                 | iscsi       |
| fsType             | Type of file to format volumes with (ext4, ext3, xfs, btrfs).                                        | xfs         |
| mountConflictDelay | Wait this long (in seconds) before forcefully taking over a volume from an isolated or crashed node. | 150         |
| flavor             | Kubernetes distribution specific tweaks. Currently only needed for `openshift`.                      | kubernetes           |
| podsMountDir       | This is the directory where the kubelet bind mounts the volume for pods. May differ between Kubernetes distributions.          | /var/lib/kubelet/pods     |
| flexVolumeExec     | This is the path where the FlexVolume binary gets installed on the host.                             | default     |
| storageClass.name  | The name to assign the created StorageClass.                                          | hpe-standard |
| storageClass.create | Enables creation of StorageClass to consume this hpe-flexvolume-driver instance.                              | true        |
| storageClass.defaultClass | Whether to set the created StorageClass as the clusters default StorageClass.                                  | false       |

It's recommended to create a [values.yaml](https://github.com/hpe-storage/co-deployments/tree/master/helm/charts/hpe-flexvolume-driver/values.yaml) file and edit it to fit the environment the chart is being deployed to. Download and edit the sample file.

### Platform notes
Certain distributions demand certain tweaks to the variables for the driver and dynamic provisioner to operate correctly. See each platform for details.

#### Upstream Kubernetes
This is the default operating mode, no tweaks are needed.

#### Red Hat OpenShift and OKD
Applicable to Red Hat OpenShift 3.10 and 3.11. 4.x is not supported.

| Key        | Value                     | Description                                                                        |
|------------|---------------------------|------------------------------------------------------------------------------------|
| podsMountDir | /var/lib/origin/openshift.local.volumes       | This is the directory where the kubelet bind mounts the volume for pods.            |

## Installing the Chart
To install the chart with the name `hpe-flexvolume`:

```
helm repo add hpe https://hpe-storage.github.io/co-deployments
helm install -f myvalues.yml --name hpe-flexvolume hpe/hpe-flexvolume-driver --namespace kube-system
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
--set protocol=iscsi --set fsType=xfs --set mountConflictDelay=120
```

## Using the HPE FlexVolume Driver for Kubernetes
To enable dynamic provisioning of `PersistentVolume` through the use of `PersistentVolumeClaim` API objects, a `StorageClass` needs to be declared on the cluster. Please see the [HPE FlexVolume Driver for Kubernetes](https://github.com/hpe-storage/flexvolume-driver) repository for the official documentation for this Helm chart. Also, it's helpful to be familar with [persistent storage concepts](https://kubernetes.io/docs/concepts/storage/volumes/) in Kubernetes prior to deploying stateful workloads.

## Support
The HPE FlexVolume Driver for Kubernetes Helm chart is supported by the respective platform team. Currently supported platforms:

- HPE Nimble Storage

Please file issues through the regular support channels for the particular platform. Feature requests or general questions to developers may be filed through the [GitHub issue tracker](https://github.com/hpe-storage/co-deployments) for this project.

You may also join our Slack community to chat with HPE folks close to this project for inquiries not requring our immediate response. We hang out in `#NimbleStorage` and `#Kubernetes` at [slack.hpedev.io](https://slack.hpedev.io/).

## Contributing
We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR. More details in [CONTRIBUTING.md](https://github.com/hpe-storage/co-deployments/blob/master/CONTRIBUTING.md)

## License
This is open source software licensed using the Apache License 2.0. Please see [LICENSE](https://github.com/hpe-storage/co-deployments/blob/master/LICENSE) for details.
