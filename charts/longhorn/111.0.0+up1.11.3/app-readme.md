# Longhorn

Longhorn is a lightweight, reliable and easy to use distributed block storage system for Kubernetes. Once deployed, users can leverage persistent volumes provided by Longhorn.

Longhorn creates a dedicated storage controller for each volume and synchronously replicates the volume across multiple replicas stored on multiple nodes. The storage controller and replicas are themselves orchestrated using Kubernetes. Longhorn supports snapshots, backups and even allows you to schedule recurring snapshots and backups!

**Important**: Please install Longhorn chart in `longhorn-system` namespace only.

**Warning**: Longhorn doesn't support downgrading from a higher version to a lower version.

[Chart Documentation](https://github.com/longhorn/longhorn/blob/master/chart/README.md)


## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API.

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `enablePSP` set to `false` if it has been previously set to `true`.

> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.

Upon setting `enablePSP` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.

As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.