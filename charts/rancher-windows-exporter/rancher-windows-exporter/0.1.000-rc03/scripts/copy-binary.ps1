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

Create-Directory -Path "c:\host\etc\windows-exporter"
Transfer-File -Src "c:\etc\windows-exporter\windows-exporter.exe" -Dst "c:\host\etc\windows-exporter\windows-exporter.exe"