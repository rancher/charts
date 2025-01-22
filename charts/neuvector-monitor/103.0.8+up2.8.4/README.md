# NeuVector Helm Chart

Helm chart for NeuVector's monitoring services.

## Configuration

The following table lists the configurable parameters of the NeuVector chart and their default values.

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----
`registry` | NeuVector container registry | `registry.neuvector.com` |
`oem` | OEM release name | `nil` |
`leastPrivilege` | Assume monitor chart is always installed after the core chart, so service accounts created by the core chart will be used. Keep this value as same as in the core chart. | `false` |
`exporter.enabled` | If true, create Prometheus exporter | `false` |
`exporter.image.repository` | exporter image name | `neuvector/prometheus-exporter` |
`exporter.image.tag` | exporter image tag | `latest` |
`exporter.ctrlSecretName` | existing secret that have CTRL_USERNAME and CTRL_PASSWORD fields to login to the controller.  | `nil` | if parameter exists then `exporter.CTRL_USERNAME` & `exporter.CTRL_PASSWORD` will be skipped
`exporter.CTRL_USERNAME` | Username to login to the controller. Suggest to replace the default admin user to a read-only user | `admin` |
`exporter.CTRL_PASSWORD` | Password to login to the controller. | `admin` |
`exporter.enforcerStats.enabled` | If true, enable the Enforcers stats | `false` | For the performance reason, by default the exporter does NOT pull CPU/memory usage from enforcers.
---

