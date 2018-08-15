# Longhorn

Longhorn is a lightweight, reliable and easy to use distributed block sotrage system for Kubernetes. Once deployed, users can leverage peristenv volumes provided by Longhorn.

Longhorn creates a dedicated storage controller for each volume and synchronously replicates the volume across multiple replicas stored on multiple nodes. The storage controller and replicas are themselves orchestrated using Kubernetes.  Longhorn supports snapshots, backups and even allows you to schedule recurring snapshots and backups!
