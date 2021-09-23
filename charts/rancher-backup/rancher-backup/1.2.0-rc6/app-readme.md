# Rancher Backup

This chart enables ability to capture backups of the Rancher application and restore from these backups. This chart can be used to migrate Rancher from one Kubernetes cluster to a different Kubernetes cluster.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/).

This chart installs the following components:

- [backup-restore-operator](https://github.com/rancher/backup-restore-operator)
  - The operator handles backing up all Kubernetes resources and CRDs that Rancher creates and manages from the local cluster. It gathers these resources by querying the Kubernetes API server, packages all the resources to create a tarball file and saves it in the configured backup storage location.
  - The operator can be configured to store backups in S3-compatible object stores such as AWS S3 and MinIO, and in persistent volumes. During deployment, you can create a default storage location, but there is always the option to override the default storage location with each backup, but will be limited to using an S3-compatible object store.
  - It preserves the ownerReferences on all resources, hence maintaining dependencies between objects.
  - This operator provides encryption support, to encrypt user specified resources before saving them in the backup file. It uses the same encryption configuration that is used to enable [Kubernetes Encryption at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).
- Backup - A backup is a CRD (`Backup`) that defines when to take backups, where to store the backup and what encryption to use (optional). Backups can be taken ad hoc or scheduled to be taken in intervals.
- Restore - A restore is a CRD (`Restore`) that defines which backup to use to restore the Rancher application to.
