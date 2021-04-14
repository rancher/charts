$ErrorActionPreference = 'Stop'

# Sleep forever, since a DaemonSet's restartPolicy must be Always
while(1) { Start-Sleep -s 3600 }