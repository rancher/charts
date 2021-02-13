# rancher-wins-upgrader

A Rancher chart that handles keeping the wins server version and config across some (or all) of the Windows nodes on a Kubernetes cluster in sync. It does this by running a simple script to replace the contents of the \etc\rancher\wins directory with the newly specified config and wins image via one or more DaemonSets. Once executed, the script will simply sleep forever.

## Cluster / Node Requirements

This Helm chart is intended to be used on a Windows cluster that is already running a wins server on each of the hosts based on a binary located in some prefixPath that contains the `\etc\rancher\wins\wins.exe` (the binary that is being watched by a Windows service) and `\etc\rancher\wins\config` (the configuration for the wins server). 

If the cluster you are installing this chart on is a custom cluster that was created via RKE1 with Windows Support enabled, your nodes should already have the wins server running; this should have been added as part of [the bootstrapping process for adding the Windows node onto your RKE1 cluster](https://github.com/rancher/rancher/blob/master/package/windows/bootstrap.ps1).