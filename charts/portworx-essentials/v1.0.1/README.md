# Portworx Essentials
[Portworx Essentials](https://docs.portworx.com/concepts/portworx-essentials/) is a free Portworx license with limited functionality that allows you to run small production or proof-of-concept workloads. Essentials limits capacity and advanced features, but otherwise functions the same way as the fully-featured PX-Enterprise version of Portworx.

The Portworx Essentials license requires that your clusters be connected to the internet and send usage data to PX-Central. Portworx Essentials clusters connect with PX-Central once per hour to renew license leases. Lease periods last for 24 hours, ensuring that any temporary interruptions to your connectivity do not impact your cluster.

## **Pre-requisites**

The minimum supported size for a Portworx cluster is three nodes. Each node must meet the following hardware, software, and network requirements:

### Hardware & Software
	
|Resource|Requirements|
|--------|------------|
|CPU|4 cores|
|RAM|4GB|
|Disk (/var)| 2GB free|
|Backing drive|8GB (minimum required) 128 GB (minimum recommended)|
|Storage drives| Minimum: 1 node with a storage drive. Storage drives must be unmounted block storage: raw disks, drive partitions, LVM, or cloud block storage. |
|Ethernet NIC card| 10 GB (recommended)|
|Linux kernel| 	Version 3.10 or greater.|
|Docker| 	Version 1.13.1 or greater.|
|Disable swap| 	Please disable swap on all nodes that will run the Portworx software. Ensure that the swap device is not automatically mounted on server reboot.|

### Network 	
Open needed ports :	TCP ports 9001-9022 and UDP port 9002 on all Portworx nodes. Also open the KVDB port. (As an example, etcd typically runs on port 2379). If you intend to use Portworx with sharedV4 volumes, you may need to open your NFS ports.

Please read [this link](https://docs.portworx.com/concepts/portworx-essentials/) before installing to understand the pre-requisites.

## **Limitations**
* The portworx helm chart can only be deployed in the kube-system namespace. Hence use "kube-system" in the "Target namespace" during configuration.

## **Uninstalling the Chart**

#### You can uninstall Portworx using one of the following methods:

#### **1. Delete all the Kubernetes components associated with the chart and the release.**

> **Note** > The Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

To perform this operation simply delete the application from the Apps page

#### **2. Wipe your Portworx installation**
> **Note** > The commands in this section are disruptive and will lead to data loss. Please use caution..

See more details [here](https://docs.portworx.com/portworx-install-with-kubernetes/install-px-helm/#uninstall)

## **Documentation**
* [Portworx docs site](https://docs.portworx.com/install-with-other/rancher/rancher-2.x/#step-1-install-rancher)
* [Portworx interactive tutorials](https://docs.portworx.com/scheduler/kubernetes/px-k8s-interactive.html)

## **Installing the Chart using the CLI**

See the installation details [here](https://docs.portworx.com/portworx-install-with-kubernetes/install-px-helm/)

## **Installing Portworx on AWS**

See the installation details [here](https://docs.portworx.com/cloud-references/auto-disk-provisioning/aws)
