# Portworx

## **Pre-requisites**

Use this Helm chart to deploy [Portworx](https://portworx.com/) and [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) to your Kubernetes cluster.


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
