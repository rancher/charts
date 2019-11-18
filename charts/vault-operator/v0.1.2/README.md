## Overview
The Vault operator deploys and manages [Vault][vault] clusters on Kubernetes. Vault instances created by the Vault operator are highly available and support automatic failover and upgrade.


### Project status: beta
The basic features have been completed, and while no breaking API changes are currently planned, the API can change in a backwards incompatible way before the project is declared stable.


## Configuration
Parameter | Description | Default
--------- | ----------- | -------
`rbac.create` | If true, create & use RBAC resources | `true`
`serviceAccounts.create` | If true, create the values-operator service account | `true`
`imagePullPolicy` | all containers image pull policy | `IfNotPresent`
`vaultOperator.replicaCount` | desired number of vault operator controller pod | `1`
`vaultOperator.image.repository` | vault operator container image repository | `quay.io/coreos/vault-operator`
`vaultOperator.image.tag` | vault operator container image tag | `latest`
`vaultOperator.resources` | vault operator pod resource requests & limits | `{}`
`vaultOperator.nodeSelector` | node labels for vault operator pod assignment | `{}`
`vault.node` | desired number of vault cluster nodes | `2`
`vault.version` | vault app version | `0.9.1-0`
`etcd.image.repository` | etcd container image repository | `quay.io/coreos/etcd-operator`
`etcd.image.tag` | etcd container image tag | `v0.8.3`
`ui.replicaCount` | desired number of Vault UI pod | `1`
`ui.image.repository` | Vault UI container image repository | `djenriquez/vault-ui`
`ui.image.tag` | Vault UI container image tag | `latest`
`ui.resources` | Vault UI pod resource requests & limits | `{}`
`ui.nodeSelector` | node labels for Vault UI pod assignment | `{}`
`ui.ingress.enabled` | If true, Vault UI Ingress will be created | `false`
`ui.ingress.annotations` | Vault UI Ingress annotations | `{}`
`ui.ingress.hosts` | Vault UI Ingress hostnames | `[]`
`ui.ingress.tls` | Vault UI Ingress TLS configuration (YAML) | `[]`
`ui.vault.auth` | Vault UI login method | `TOKEN`
`ui.service.name` | Vault UI service name | `vault-ui`
`ui.service.type` | type of ui service to create | `ClusterIP`
`ui.service.externalPort` | Vault UI service target port | `8000`
`ui.service.internalPort` | Vault UI container port | `8000`
`ui.service.nodePort` | Port to be used as the service NodePort (ignored if `server.service.type` is not `NodePort`) | `0`


## Using the Vault cluster

See the [Vault usage guide](https://github.com/coreos/vault-operator/blob/master/doc/user/vault.md) on how to initialize, unseal, and use the deployed Vault cluster.

Consult the [monitoring guide](https://github.com/coreos/vault-operator/blob/master/doc/user/monitoring.md) on how to monitor and alert on a Vault cluster with Prometheus.

See the [recovery guide](https://github.com/coreos/vault-operator/blob/master/doc/user/recovery.md) on how to backup and restore Vault cluster data using the etcd opeartor

For an overview of the default TLS configuration or how to specify custom TLS assets for a Vault cluster see the [TLS setup guide](https://github.com/coreos/vault-operator/blob/master/doc/user/tls_setup.md).

[vault]: https://www.vaultproject.io/
[etcd-operator]: https://github.com/coreos/etcd-operator/
