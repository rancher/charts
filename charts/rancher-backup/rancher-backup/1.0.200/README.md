# Rancher Backup

This chart provides ability to back up and restore the Rancher application running on any Kubernetes cluster.

Refer [this](https://github.com/rancher/backup-restore-operator) repository for implementation details.

-----

### Get Repo Info
```
helm repo add rancher-chart https://charts.rancher.io
helm repo update
```

-----

### Install Chart
```
helm install rancher-backup-crd rancher-chart/rancher-backup-crd -n cattle-resources-system --create-namespace
helm install rancher-backup rancher-chart/rancher-backup -n cattle-resources-system
```

-----

### Configuration
The following table lists the configurable parameters of the rancher-backup chart and their default values:

| Parameter   |      Description      |  Default |
|----------|---------------|-------|
| image.repository |  Container image repository | rancher/backup-restore-operator |
| image.tag |    Container image tag  |   v0.1.0-rc1 |
| s3.enabled | Configure S3 compatible default storage location. Current version supports S3 and MinIO |    false |
| s3.credentialSecretName | Name of the Secret containing S3 credentials. This is an optional field. Skip this field in order to use IAM Role authentication. The Secret must contain following two keys, `accessKey` and `secretKey` |    "" |
| s3.credentialSecretNamespace | Namespace of the Secret containing S3 credentials |    "" |
| s3.region | Region of the S3 Bucket (Required for S3, not valid for MinIO) |    "" |
| s3.bucketName | Name of the Bucket |    "" |
| s3.folder | Base folder within the Bucket (optional) |    "" |
| s3.endpoint | Endpoint for the S3 storage provider |   "" |
| s3.endpointCA | Base64 encoded CA cert for the S3 storage provider (optional) | "" |
| s3.insecureTLSSkipVerify |  Skip SSL verification | false |
| persistence.enabled |  Configure a Persistent Volume as the default storage location. It accepts either a StorageClass name to create a PVC, or directly accepts the PV to use. The Persistent Volume is mounted at `/var/lib/backups` in the operator pod | false |
| persistence.storageClass |  StorageClass to use for dynamically provisioning the Persistent Volume, which will be used for storing backups | "" |
| persistence.volumeName |  Persistent Volume to use for storing backups | "" |
| persistence.size |  Requested size of the Persistent Volume (Applicable when using dynamic provisioning) | "" |
| nodeSelector | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | {} |
| tolerations | https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration | [] |
| affinity | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | {} |

-----

### CRDs

Refer [this](https://github.com/rancher/backup-restore-operator#crds) section for information on CRDs that this chart installs. Also refer [this](https://github.com/rancher/backup-restore-operator/tree/master/examples) folder containing sample manifests for the CRDs.

-----
### Upgrading Chart
```
helm upgrade rancher-backup-crd -n cattle-resources-system
helm upgrade rancher-backup -n cattle-resources-system
```

-----
### Uninstall Chart

```
helm uninstall rancher-backup -n cattle-resources-system
helm uninstall rancher-backup-crd -n cattle-resources-system
```

