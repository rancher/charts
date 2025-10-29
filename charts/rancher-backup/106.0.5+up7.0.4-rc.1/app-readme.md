# Rancher Backup

This chart enables ability to capture backups of the Rancher application and restore from these backups. This chart can be used to migrate Rancher from one Kubernetes cluster to a different Kubernetes cluster.

For more information on how to use the feature, refer to our [docs](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/backup-restore-and-disaster-recovery).

This chart installs the following components:

- [backup-restore-operator](https://github.com/rancher/backup-restore-operator)
  - The operator handles backing up all Kubernetes resources and CRDs that Rancher creates and manages from the local cluster. It gathers these resources by querying the Kubernetes API server, packages all the resources to create a tarball file and saves it in the configured backup storage location.
  - The operator can be configured to store backups in S3-compatible object stores such as AWS S3 and MinIO, and in persistent volumes. During deployment, you can create a default storage location, but there is always the option to override the default storage location with each backup, but will be limited to using an S3-compatible object store.
  - It preserves the ownerReferences on all resources, hence maintaining dependencies between objects.
  - This operator provides encryption support, to encrypt user specified resources before saving them in the backup file. It uses the same encryption configuration that is used to enable [Kubernetes Encryption at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).
- Backup - A backup is a CRD (`Backup`) that defines when to take backups, where to store the backup and what encryption to use (optional). Backups can be taken ad hoc or scheduled to be taken in intervals.
- Restore - A restore is a CRD (`Restore`) that defines which backup to use to restore the Rancher application to.

## Upgrading to Kubernetes v1.25+
    ​
Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API. 
    ​
As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.
​    
> **Note:**
> In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.
    ​
> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.
​
Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.
​
As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.
