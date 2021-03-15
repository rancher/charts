$ErrorActionPreference = 'Stop'

function Create-Directory
{
    param (
        [parameter(Mandatory = $false, ValueFromPipeline = $true)] [string]$Path
    )

    if (Test-Path -Path $Path) {
        if (-not (Test-Path -Path $Path -PathType Container)) {
            # clean the same path file
            Remove-Item -Recurse -Force -Path $Path -ErrorAction Ignore | Out-Null
        }

        return
    }

    New-Item -Force -ItemType Directory -Path $Path | Out-Null
}

function Transfer-File
{
    param (
        [parameter(Mandatory = $true)] [string]$Src,
        [parameter(Mandatory = $true)] [string]$Dst
    )

    if (Test-Path -PathType leaf -Path $Dst) {
        $dstHasher = Get-FileHash -Path $Dst
        $srcHasher = Get-FileHash -Path $Src
        if ($dstHasher.Hash -eq $srcHasher.Hash) {
            return
        }
    }

    $null = Copy-Item -Force -Path $Src -Destination $Dst
}

if ($env:WINS_UPGRADE_PATH) {
    $winsUpgradePath = $env:WINS_UPGRADE_PATH
} else {
    $winsUpgradePath = "c:\etc\rancher\wins\wins-upgrade.exe"
}
$winsUpgradeDir = Split-Path -Path $winsUpgradePath
$winsUpgradeFilename = Split-Path -Path $winsUpgradePath -Leaf

Create-Directory -Path $winsUpgradeDir
Transfer-File -Src "c:\Windows\wins.exe" -Dst $winsUpgradePath

Create-Directory -Path "c:\host\etc\rancher\wins"
Transfer-File -Src $winsUpgradePath -Dst "c:\host\etc\rancher\wins\$winsUpgradeFilename"
Transfer-File -Src "c:\scripts\config" -Dst "c:\host\etc\rancher\wins\config"

$winsOut = wins.exe cli prc run --path=$winsUpgradePath --args="up --wins-args=`'--config=$winsUpgradeDir\config`'"

Write-Host $winsOut

if ($winsOut -match ".* rpc error: code = Unavailable desc = transport is closing") {
    Write-Host "Successfully upgraded"
    exit 0
} elseif ($LastExitCode -ne 0) {
    Write-Host "Returned exit $LastExitCode"
    exit $LastExitCode
} else {
    Write-Host "Returned exit 0, but did not receive expected output from .\wins up"
    exit 1
}
