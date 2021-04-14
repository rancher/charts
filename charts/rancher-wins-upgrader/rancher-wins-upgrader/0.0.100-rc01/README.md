# Rancher Wins Upgrader

A Rancher chart that handles keeping the wins server version and config across some (or all) of the Windows nodes on a Kubernetes cluster in sync. It does this by running a simple script to replace the contents of the `\etc\rancher\wins` directory with the newly specified config and wins image via one or more DaemonSets. Once executed, the script will simply sleep forever.

## How does this work?

A DaemonSet of initContainers copies the provided config (stored in a ConfigMap) into `\etc\rancher\wins\config` and runs `wins cli prc run --path {path-to-wins} --args {up}`, where `.\wins up[grade]` is a Go program that runs a simple Powershell script that forces an upgrade of the binary used by the `rancher-wins` service across all of your Windows hosts.

TLDR: we use wins (cli) to pass wins (upgrade) to wins (server) in order to update wins (server) on the host on demand.

## Cluster / Node Requirements

This Helm chart is intended to be used on a Windows cluster that meets the following two requirements:
- A Windows Service called `rancher-wins` is currently running on each Windows host (e.g. `.\wins srv app run --register; Start-Service -Name rancher-wins` or `.\wins up` has been run on the host) that is running a wins server version of v0.1.0+.
- The wins config used by each Windows host's `rancher-wins` Service has `{{ .Values.prefixPath }}etc\rancher\wins\wins-upgrade.exe` within `whiteList.processPath` so that the new wins version can be delivered onto the host

If the cluster you are installing this chart on is a custom cluster that was created via RKE1 with Windows Support enabled, your nodes should already meet the first requirement; this should have been added as part of [the bootstrapping process for adding the Windows node onto your RKE1 cluster](https://github.com/rancher/rancher/blob/master/package/windows/bootstrap.ps1).

However, depending on the bootstrap.ps1 version that was used when you spun up your Windows cluster, it is possible that the second requirement is not met yet. 

If the second requirement is not met, there are two options to reconcile:

### Manual Update

This is the recommended approach for updating your Windows hosts, but it requires the user to log onto every Windows host to upgrade the wins config. After logging onto each host, you will need to do manually update the wins config.

By default, the wins config is located in `c:\etc\rancher\wins\config`, but you could use the following powershell command to identify the command line arguments passed into the `rancher-wins` service (`--config` corresponds to the config path on the host):
```powershell
(Get-CimInstance Win32_Service -Filter 'Name = "rancher-wins"').PathName
```

Once complete, restart the service:
```powershell
Restart-Service -Name "rancher-wins" | Stop-Service
```

### Masquerading (Use at your own risk. Here be dragons...)

This option is *only* meant as a hack to allow users who are currently operating on Windows clusters that have not whitelisted `{{ .Values.prefixPath }}etc\rancher\wins\wins-upgrade.exe`. If you plan to use this option, please ensure that you immediately upgrade this chart with `masquerade.enabled=false` and perform another `helm upgrade` to avoid any unintentional consequences (e.g. failure to install the original process that you meant to whitelist on the host).

If `masquerade.enabled=True`, this chart will have the wins client execute `wins-upgrade.exe` payload under the `masquerade.as` path provided, effectively tricking the `wins server` into running the binary although it has not been whitelisted. This relies on the fact that the wins server does not / cannot do any verification on the binary passed into wins since it does track a list of valid checksums on the binaries provided to it.