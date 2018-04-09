# nfs-provisioner

nfs-provisioner is an out-of-tree dynamic provisioner for Kubernetes. You can use it to quickly & easily deploy shared storage that works almost anywhere. 
Or it can help you write your own out-of-tree dynamic provisioner by serving as an example implementation of the requirements detailed in the proposal. 

## Introduction

It works just like in-tree dynamic provisioners: a `StorageClass` object can specify an instance of nfs-provisioner to be its `provisioner` like it specifies in-tree provisioners such as GCE or AWS. Then, the instance of nfs-provisioner will watch for `PersistentVolumeClaims` that ask for the `StorageClass` and automatically create NFS-backed `PersistentVolumes` for them. For more information on how dynamic provisioning works, see [the docs](http://kubernetes.io/docs/user-guide/persistent-volumes/) or [this blog post](http://blog.kubernetes.io/2016/10/dynamic-provisioning-and-storage-in-kubernetes.html).

## Prerequisites

- Kubernetes 1.5+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Uninstalling the Chart

If you have chart using this storageClass as dynamic provisioner, please backup the data and remove all the relevant chart before uninstall the nfs chart.

Lastly click `Delete` from the Catalog page will removes all the Kubernetes components associated with the nfs chart and deletes the release.


---
Please see [this example](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
for more information.
