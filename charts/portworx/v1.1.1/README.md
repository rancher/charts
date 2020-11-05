# Portworx

## **Pre-requisites**

Use this Helm chart to deploy [Portworx](https://portworx.com/) and [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) to your Kubernetes cluster.

Prerequisites

Refer to the [Install Portworx on Kubernetes via Helm](https://docs.portworx.com/portworx-install-with-kubernetes/install-px-helm/#pre-requisites) page for the list of prerequisites.

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

## ** Giving your etcd certificates to Portworx using Kubernetes Secrets.**
This is the recommended way of providing etcd certificates, as the certificates will be automatically available to the new nodes joining the cluster

* Create Kubernetes secret
* Copy all your etcd certificates and key in a directory etcd-secrets/ to create a Kubernetes secret from it. Make sure the file names are the same as you gave above.

```
# ls -1 etcd-secrets/
etcd-ca.crt
etcd.crt
etcd.key
```

* Use kubectl to create the secret named px-etcd-certs from the above files:
```
# kubectl -n kube-system create secret generic px-etcd-certs --from-file=etcd-secrets/
```

* Notice that the secret has 3 keys etcd-ca.crt, etcd.crt and etcd.key, corresponding to file names in the etcd-secrets folder. We will use these keys in the Portworx spec file to reference the certificates.

```
# kubectl -n kube-system describe secret px-etcd-certs
Name:         px-etcd-certs
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
etcd-ca.crt:      1679 bytes
etcd.crt:  1680 bytes
etcd.key:  414  bytes
```
Once above secret is created, proceed to the next steps.
