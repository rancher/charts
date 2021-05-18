# NFS Server Provisioner

[NFS Server Provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) is an out-of-tree dynamic provisioner for Kubernetes. You can use it to quickly & easily deploy shared storage that works almost anywhere.

This provisioner includes a built in NFS server, and is not intended for connecting to a pre-existing NFS server.

## Tips:
It's recommended to constrain the nfs-provisoner server to run on a particular Node using nodeSelector, you can add nodeSelector using `Edit as YAML`:
```
nodeSelector:
  nfs-provisioner: server # specify your key:value nodeSelector
```
