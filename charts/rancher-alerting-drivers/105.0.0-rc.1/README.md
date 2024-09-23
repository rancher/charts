# Rancher Alerting Drivers

This chart installs one or more [Alertmanager Webhook Receiver Integrations](https://prometheus.io/docs/operating/integrations/#alertmanager-webhook-receiver) (i.e. Drivers).

Those Drivers can be targeted by an existing deployment of Alertmanager to send alerts to notification mechanisms that are not natively supported.

Currently, this chart supports the following Drivers:
- Microsoft Teams, based on [prom2teams](https://github.com/idealista/prom2teams)
- SMS, based on [Sachet](https://github.com/messagebird/sachet)

After installing rancher-alerting-drivers, please refer to the upstream documentation for each Driver for configuration options.