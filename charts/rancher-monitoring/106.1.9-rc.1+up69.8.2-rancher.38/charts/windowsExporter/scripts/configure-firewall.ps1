$ErrorActionPreference = 'Continue'

function CheckFirewallRuleError {
    # We hit an error. This can happen for a number of reasons, including if the rule already exists
    if ($error[0]) {
        if (($error[0].Exception.NativeErrorCode) -and ($error[0].Exception.NativeErrorCode.ToString() -eq "AlreadyExists")) {
            # Previous versions of monitoring may have already created this Firewall Rule
            # Because of this, if the rule alreadys exists there is no need to delete and recreate it.
            Write-Host "Detected Existing Firewall Rule, Nothing To Do"
        } else {
            Write-Host "Error Encountered Setting Up Required Firewall Rule"
            $error[0].Exception
            exit 1
        }
    }
}

Write-Host "Attempting To Configure Firewall Rules For Ports 9796, 10250"

# This is the exact same firewall rule that has historically been created by rancher-wins
# https://github.com/rancher/wins/blob/91f670c47f19c6d9fe97d8f66a695d3081ad994f/pkg/apis/process_service_mgmt.go#L149
New-NetFirewallRule -DisplayName rancher-wins-windows-exporter-TCP-9796 -Name rancher-wins-windows-exporter-TCP-9796 -Action Allow -Protocol TCP -LocalPort 9796 -Enabled True -PolicyStore ActiveStore
CheckFirewallRuleError
Write-Host "Windows Node Exporter Firewall Rule Successfully Created"

# This rule is required in order to have the Rancher UI display node metrics in the 'Nodes' tab of the cluster explorer
New-NetFirewallRule -DisplayName rancher-wins-windows-exporter-TCP-10250 -Name rancher-wins-windows-exporter-TCP-10250 -Action Allow -Protocol TCP -LocalPort 10250 -Enabled True -PolicyStore ActiveStore
CheckFirewallRuleError
Write-Host "Windows Prometheus Metrics Firewall Rule Successfully Created"

Write-Host "All Firewall Rules Successfully Configured"
