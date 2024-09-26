$ErrorActionPreference = 'Continue'

# Previous installations of monitoring may have used wins to deploy the windows_node-exporter.
# If this is the case, then port 9796 is likely still occupied by the process spawned from wins
# (even though the old verson of monitoring has been uninstalled / upgraded). Since we need to continue
# to use port 9796, we have clean up the old process before starting the exporter container.
$existingProcess = $(Get-Process -Id (Get-NetTCPConnection -LocalPort 9796).OwningProcess)

# Port is free, nothing to do
if (-not $existingProcess) {
    exit 0
}

# If windows_node-exporter was launched from rancher wins the process name will alwawys
# be prefixed with 'rancher-wins-' (https://github.com/rancher/wins/blob/91f670c47f19c6d9fe97d8f66a695d3081ad994f/pkg/apis/process_service.go#L20)
# Instances of windows-exporter not launched from wins will simply be titled 'windows-exporter'.
if ($existingProcess.Name -eq "rancher-wins-windows-exporter") {
    Write-Host "Cleaning up outdated windows-node-exporter process spawned from rancher-wins"
    Stop-Process $existingProcess.Id
    Write-Host "Successfully removed outdated windows-node-exporter process"
}

# If this is the first time monitoring is being installed onto a cluster but an unrelated process
# is occupying port 9796, we need to error out and state that the required port is not free.
if (-not ($existingProcess.Name -like "rancher")) {
    Write-Host Error encountered setting up windows_node-exporter. An unrelated process is occupying required port 9796 ($existingProcess.Name). Port 9796 must be available in order to install rancher-monitoring.
    exit 1
}
