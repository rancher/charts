# Longhorn

Longhorn is a distributed block storage system for Kubernetes. Longhorn is lightweight, reliable, and easy-to-use. You can deploy Longhorn on an existing Kubernetes cluster with one simple command. Once Longhorn is deployed, it adds persistent volume support to the Kubernetes cluster.

Longhorn implements distributed block storage using containers and microservices. Longhorn creates a dedicated storage controller for each block device volume and sychronously replicates the volume across multiple replicas stored on multiple nodes. The storage controller and replicas are themselves orchestrated using Kubernetes. Longhorn supports snapshots, backups, and even allows you to schedule recurring snapshots and backups!

