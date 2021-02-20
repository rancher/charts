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

Create-Directory -Path "c:\etc\rancher\wins"
Transfer-File -Src "c:\Windows\wins.exe" -Dst "c:\etc\rancher\wins\wins-upgrade.exe"

Create-Directory -Path "c:\host\etc\rancher\wins"
Transfer-File -Src "c:\etc\rancher\wins\wins-upgrade.exe" -Dst "c:\host\etc\rancher\wins\wins-upgrade.exe"
Transfer-File -Src "c:\scripts\config" -Dst "c:\host\etc\rancher\wins\config"

$winsPath = "c:\etc\rancher\wins\wins-upgrade.exe"
$winsArgs = $('up')

wins.exe cli prc run --path $winsPath --args "$winsArgs"

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Remove-Item -Force -Path "c:\host\etc\rancher\wins\wins-upgrade.exe"