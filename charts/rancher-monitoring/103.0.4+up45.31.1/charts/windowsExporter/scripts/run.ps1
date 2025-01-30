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

# Copy binary into host
Create-Directory -Path "c:\host\etc\windows-exporter"
Transfer-File -Src "c:\etc\windows-exporter\windows-exporter.exe" -Dst "c:\host\etc\windows-exporter\windows-exporter.exe"

# Copy binary into prefix path, since wins expects the same path on the host and on the container
$prefixPath = 'c:\'
if ($env:CATTLE_PREFIX_PATH) {
    $prefixPath = $env:CATTLE_PREFIX_PATH
}
$winsDirPath = $('{0}etc\windows-exporter' -f $prefixPath)
$winsPath = $('{0}\windows-exporter.exe' -f $winsDirPath)

Create-Directory -Path $winsDirPath
Transfer-File -Src "c:\etc\windows-exporter\windows-exporter.exe" $winsPath

# Run wins with defaults
$listenPort = "9796"
$enabledCollectors = "net,os,service,system,cpu,cs,logical_disk"
$maxRequests = "5"

if ($env:LISTEN_PORT) {
    $listenPort = $env:LISTEN_PORT
}

if ($env:ENABLED_COLLECTORS) {
    $enabledCollectors = $env:ENABLED_COLLECTORS
}

if ($env:MAX_REQUESTS) {
    $maxRequests = $env:MAX_REQUESTS
}

# format "UDP:4789 TCP:8080"
$winsExposes = $('TCP:{0}' -f $listenPort)

# format "--a=b --c=d"
$winsArgs = $('--collectors.enabled={0} --telemetry.addr=:{1} --telemetry.max-requests={2} --telemetry.path=/metrics' -f $enabledCollectors, $listenPort, $maxRequests)


wins.exe cli prc run --path $winsPath --exposes $winsExposes --args "$winsArgs"
