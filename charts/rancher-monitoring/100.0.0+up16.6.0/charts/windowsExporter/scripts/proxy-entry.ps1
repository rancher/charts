# default
$listenPort = "9796"

if ($env:LISTEN_PORT) {
    $listenPort = $env:LISTEN_PORT
}

# format "UDP:4789 TCP:8080"
$winsPublish = $('TCP:{0}' -f $listenPort)

wins.exe cli proxy --publish $winsPublish
