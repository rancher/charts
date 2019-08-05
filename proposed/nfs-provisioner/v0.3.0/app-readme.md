# NFS Server Provisioner

[NFS Server Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
is an out-of-tree dynamic provisioner for Kubernetes. You can use it to quickly
& easily deploy shared storage that works almost anywhere.

This chart will deploy the Kubernetes [external-storage projects](https://github.com/kubernetes-incubator/external-storage)
`nfs` provisioner. This provisioner includes a built in NFS server, and is not intended for connecting to a pre-existing
NFS server. If you have a pre-existing NFS Server, please consider using the [NFS Client Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client)
instead.
