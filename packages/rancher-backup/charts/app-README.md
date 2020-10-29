# Rancher Backup

The Rancher Backup chart provides ability to back up and restore the Rancher application running on any Kubernetes cluster. It can be used for migrating Rancher running on one cluster to another.
-  It backs up all Kubernetes resources and CRDs that Rancher creates and manages from the local cluster. It gathers these resources by querying the Kubernetes API server, packages all resources to create a tarball file and saves it in the configured backup storage location.
- The chart can be configured to store backups in S3-compatible object stores such as AWS S3 and MinIO, and in Persistent Volumes. The [storage configuration](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/configuration/storage-config/) guide has steps for configuring these storage locations. You will have the option to override this with each backup, but will be limited to using an S3-compatible object store.
- It preserves the ownerReferences on all resources, hence maintaining dependencies between objects.
- This operator provides encryption support, to encrypt user specified resources before saving them in the backup file. It uses the same encryption configuration that is used to enable [Kubernetes Encryption at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/). Refer the [docs](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/configuration/backup-config/#encryptionconfigname) for more details.

## User flow
- **Performing a Rancher Backup**: A backup can be performed by creating a Backup custom resource. It can be configured to perform a one-time backup or recurring backups.  Refer the [backup configuration](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/configuration/backup-config/) guide for more details.
- **Restoring from a Backup**: A restore is performed by creating a Restore custom resource. Refer the [restore configuration](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/restoring-rancher/) guide for detailed steps.
- **Migrating Rancher to a new Cluster**: You can migrate Rancher running on one cluster to a different cluster by following [this](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/migrating-rancher/) guide.

For information on configuring this chart, refer the README.md of this chart.

