$ErrorActionPreference = 'Stop'

$winsPath = "c:\Windows\wins.exe"
$minWinsVersion = [System.Version]"0.1.0"

function Get-Wins-Version
{
    $winsAppInfo = Invoke-Expression "& $winsPath cli app info | ConvertFrom-Json"
    return [System.Version]($winsAppInfo.Server.Version.substring(1))
}

# Wait till the wins version installed is at least v0.1.0
$winsVersion = Get-Wins-Version
while ($winsVersion -lt $minWinsVersion) {
    Write-Host $('wins on host must be at least v{0}, found v{1}. Checking again in 10 seconds...' -f $minWinsVersion, $winsVersion)
    Start-Sleep -s 10
    $winsVersion = Get-Wins-Version
}

Write-Host $('Detected wins version on host is v{0}, which is >v{1}. Continuing with installation...' -f $winsVersion, $minWinsVersion)
