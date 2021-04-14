# Rancher Wins Upgrader

A Rancher chart that handles keeping the wins server version and config across some (or all) of the Windows nodes on a Kubernetes cluster in sync. It does this by running a simple script to replace the contents of the `\etc\rancher\wins` directory with the newly specified config and wins image via one or more DaemonSets. Once executed, the script will simply sleep forever.

## How does this work?

A DaemonSet of initContainers copies the provided config (stored in a ConfigMap) into `\etc\rancher\wins\config` and runs `wins cli prc run --path {path-to-wins} --args {up}`, where `.\wins up[grade]` is a Go program that runs a simple Powershell script that forces an upgrade of the binary used by the `rancher-wins` service across all of your Windows hosts.

TLDR: we use wins (cli) to pass wins (upgrade) to wins (server) in order to update wins (server) on the host on demand.

## Cluster / Node Requirements

This Helm chart is intended to be used on a Windows cluster that meets the following two requirements:
- A Windows Service called `rancher-wins` is currently running on each Windows host (e.g. `.\wins srv app run --register; Start-Service -Name rancher-wins` or `.\wins up` has been run on the host) that is running a wins server version of v0.1.0+.
- The wins config used by each Windows host's `rancher-wins` Service has `{{ .Values.prefixPath }}etc\rancher\wins\wins-upgrade.exe` within `whiteList.processPath` so that the new wins version can be delivered onto the host

If the cluster you are installing this chart on is a custom cluster that was created via RKE1 with Windows Support enabled after wins v0.1.0+ was released (i.e. Rancher 2.5.7+), your nodes should already meet the first requirement; this should have been added as part of [the bootstrapping process for adding the Windows node onto your RKE1 cluster](https://github.com/rancher/rancher/blob/master/package/windows/bootstrap.ps1).

If not, please see the README.md for more information on how you can use this chart.