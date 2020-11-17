# StorageOS Operator

[StorageOS](https://storageos.com) is a cloud native, software-defined storage
platform that transforms commodity server or cloud based disk capacity into
enterprise-class persistent storage for containers. StorageOS is ideal for
deploying databases, message busses, and other mission-critical stateful
solutions, where rapid recovery and fault tolerance are essential.

The StorageOS Operator installs and manages StorageOS within a cluster.
Cluster nodes may contribute local or attached disk-based storage into a
distributed pool, which is then available to all cluster members via a
global namespace.

By default, a minimal configuration of StorageOS is installed. To set advanced
configurations, disable the default installation of StorageOS and create a
custom StorageOSCluster resource
([documentation](https://docs.storageos.com/docs/reference/cluster-operator/examples)).

`Notes: The StorageOS Operator must be installed in the System Project with
Cluster Role`
