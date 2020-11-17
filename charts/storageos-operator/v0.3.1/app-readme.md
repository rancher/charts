# StorageOS Operator

StorageOS is a cloud native, software-defined storage platform that transforms
commodity server or cloud based disk capacity into enterprise-class persistent
storage for containers. StorageOS volumes offer high throughput, low latency
and consistent performance, and are therefore ideal for deploying databases,
message queues, and other mission-critical stateful solutions.

The StorageOS Operator installs and manages StorageOS within a cluster. Cluster
nodes may contribute local or attached disk-based storage into a distributed
pool, which is then available to all cluster members via a global namespace.

Volumes are available across the cluster so if an application container gets
moved to another node it has immediate access to re-attach its data.

StorageOS is extremely lightweight - minimum requirements are a reserved CPU
core and 2GB of free memory. There are minimal external dependencies, and no
custom kernel modules.

After StorageOS is installed, please register for a free Developer license to
enable 5TiB of capacity and HA with synchronous replication by following the
instructions [here](https://docs.storageos.com/docs/operations/licensing). For
additional capacity, features and support plans contact sales@storageos.com.

## Highlighted Features

* High Availability - synchronous replication insulates you from node failure.
* Delta Sync - replicas out of sync due to transient failures only transfer
    changed blocks.
* Scalability - disaggregated consensus means no single scheduling point of
    failure.
* Thin provisioning - Only consume the space you need in a storage pool.
* Data reduction - Transparent inline data compression to reduce the amount of
    storage used in a backing store as well as reducing the network bandwidth
    requirements for replication.
* Flexible configuration - all features can be enabled per volume, using PVC
    and StorageClass labels.
* Multi-tenancy - fully supports standard Namespace and RBAC methods.
* Observability & instrumentation - Log streams for observability and
    Prometheus support for instrumentation.
* Deployment flexibility - Scale up or scale out storage based on application
    requirements. Works with any infrastructure – on-premises, VM, bare metal
    or cloud.

## About StorageOS

StorageOS is a software-defined cloud native storage platform delivering
persistent storage for Kubernetes. StorageOS is built from the ground-up with
no legacy restrictions to give enterprises working with cloud native workloads
a scalable storage platform with no compromise on performance, availability or
security. For additional information, visit www.storageos.com.

## Installation

StorageOS requires an etcd cluster in order to function. Find out more about
setting up an etcd cluster in our [etcd
docs](https://docs.storageos.com/docs/prerequisites/etcd/).

By default, a minimal configuration of StorageOS is installed. To set advanced
configurations, disable the default installation of StorageOS and create a
custom StorageOSCluster resource
([documentation](https://docs.storageos.com/docs/reference/cluster-operator/examples)).

Newly installed StorageOS clusters require a license to function. For
instructions on applying our free developer license, or obtaining a commercial
license, please see our documentation at
https://docs.storageos.com/docs/reference/licence/.

> **Notes**:
> - The StorageOS Operator must be installed in the System Project with Cluster
> Role.
> - To upgrade from StorageOS version 1.x to 2.x, please contact support
> for assistance.
