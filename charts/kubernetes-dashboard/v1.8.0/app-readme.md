# kubernetes-dashboard

[Kubernetes Dashboard](https://github.com/kubernetes/dashboard) is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

## Access control

IMPORTANT: 

You must be a cluster admin to be able to deploy Kubernetes Dashboard. 

WARNING: 

Once the Dashboard is deployed with cluster admin role, anyone with access to this project can access the Dashboard and therefore gain access to the entire Kubernetes cluster!!!

It is critical for the Kubernetes cluster to correctly setup access control of Kubernetes Dashboard. See this [guide](https://github.com/kubernetes/dashboard/wiki/Access-control) for best practises.

It is highly recommended to use RBAC with minimal privileges needed for Dashboard to run.

`Notes: Dashboard is required to be installed in the System Project`
