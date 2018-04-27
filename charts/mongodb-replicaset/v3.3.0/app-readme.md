# MongoDB Helm Chart

## Prerequisites Details
* Kubernetes 1.8+ with Beta APIs enabled.
* PV support on the underlying infrastructure.

## Chart Details

This chart implements a dynamically scalable [MongoDB replica set](https://docs.mongodb.com/manual/tutorial/deploy-replica-set/)
using Kubernetes StatefulSets and Init Containers.
