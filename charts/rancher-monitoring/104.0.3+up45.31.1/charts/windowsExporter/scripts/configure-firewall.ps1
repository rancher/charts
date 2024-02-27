$ErrorActionPreference = 'Continue'

Write-Host "Attempting to configure Firewall Rule"

# This is the exact same firewall rule that has historically been created by rancher-wins
# https://github.com/rancher/wins/blob/91f670c47f19c6d9fe97d8f66a695d3081ad994f/pkg/apis/process_service_mgmt.go#L149
New-NetFirewallRule -DisplayName rancher-wins-windows-exporter-TCP-9796 -Name rancher-wins-windows-exporter-TCP-9796 -Action Allow -Protocol TCP -LocalPort 9796 -Enabled True -PolicyStore ActiveStore

# We hit an error. This can happen for a number of reasons, including if the rule already exists
if ($error[0]) {
    if ($error[0].Exception.NativeErrorCode.ToString() -eq "AlreadyExists") {
        # Previous versions of monitoring will have already created this Firewall Rule
        # via rancher-wins. This script creates the exact same Firewall Rule as rancher-wins.
        # Because of this, if the rule alreadys exists there is no need to delete and recreate it.
        Write-Host "Detected existing Firewall Rule, nothing to do"
    } else {
        Write-Host "Error encountered setting up required Firewall Rule"
        error[0].Exception
        exit 1
    }
}

Write-Host "Firewall Rule successfully configured"
