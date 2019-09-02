# Prometheus

[Prometheus](https://prometheus.io/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

## Prometheus 2.x

Prometheus version 2.x has made changes to alertmanager, storage and recording rules. Check out the migration guide [here](https://prometheus.io/docs/prometheus/2.0/migration/)

Users of this chart will need to update their alerting rules to the new format before they can upgrade.

## Upgrading from previous chart versions.

Version 9.0 adds a new option to enable or disable the Prometheus Server.
This supports the use case of running a Prometheus server in one k8s cluster and scraping exporters in another cluster while using the same chart for each deployment.
To install the server `server.enabled` must be set to `true`.

As of version 5.0, this chart uses Prometheus 2.x. This version of prometheus introduces a new data format and is not compatible with prometheus 1.x. It is recommended to install this as a new release, as updating existing releases will not work. See the [prometheus docs](https://prometheus.io/docs/prometheus/latest/migration/#storage) for instructions on retaining your old data.
