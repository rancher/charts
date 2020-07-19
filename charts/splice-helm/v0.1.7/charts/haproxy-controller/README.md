# SpliceDB HAProxy Controller

This Helm chart is specifically designed to run HAPROXY to forwards TCP port 1527 (jdbc) connections in to splicedb hregion servers.

## ConfigMap Setting options

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: haproxy-configmap
  namespace: splice-system
data:
  check: "enabled"
  forwarded-for: "enabled"
  load-balance: "roundrobin"
  maxconn: "2000"
  nbthread: "1"
  rate-limit: "OFF"
  rate-limit-expire: "30m"
  rate-limit-interval: "10s"
  rate-limit-size: "100k"
  servers-increment: "42"
  servers-increment-max-disabled: "66"
  ssl-certificate: "default/tls-secret"
  ssl-numproc: "1"
  ssl-redirect: "ON"
  ssl-redirect-code: "302"
  timeout-http-request: "5s"
  timeout-connect: "5s"
  timeout-client: "50s"
  timeout-queue: "5s"
  timeout-server: "50s"
  timeout-tunnel: "1h"
  timeout-http-keep-alive: "1m"
  whitelist: "127.0.0.1, 192.168.50.1/24"
  whitelist-with-rate-limit: "ON"
```
