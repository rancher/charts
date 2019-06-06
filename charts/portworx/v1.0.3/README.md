# Portworx

## **Pre-requisites**

This helm chart deploys [Portworx](https://portworx.com/) and [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) on your Kubernetes cluster. The minimum requirements for deploying the helm chart are as follows:

- All [Pre-requisites](https://docs.portworx.com/scheduler/kubernetes/install.html#prerequisites) for Portworx must be fulfilled.

## **Limitations**
* The portworx helm chart can only be deployed in the kube-system namespace. Hence use "kube-system" in the "Target namespace" during configuration.
* You can only deploy one portworx helm chart per Kubernetes cluster.

## **Uninstalling the Chart**

#### When uninstalling Portworx from your cluster, you have 2 options:

#### **1. Delete all the Kubernetes components associated with the chart and the release.**

> **Note** > The Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

To perform this operation simply delete the application from the Apps page

#### **2. Wipe your entire Portworx installation**
> **Note** > Be advised, the commands used in this section are DISRUPTIVE and will lead to loss of all your data volumes. Proceed with CAUTION.

See more details [here](https://2.1.docs.portworx.com/portworx-install-with-kubernetes/install-px-helm/#uninstall)

## **Documentation**
* [Portworx docs site](https://docs.portworx.com/install-with-other/rancher/rancher-2.x/#step-1-install-rancher)
* [Portworx interactive tutorials](https://docs.portworx.com/scheduler/kubernetes/px-k8s-interactive.html)

## **Installing the Chart using the CLI**

See the installation details [here](https://2.1.docs.portworx.com/portworx-install-with-kubernetes/install-px-helm/)
